/*
 * SRF Play – Hide Highlights Bar  (content script)
 *
 * The actual hiding/collapsing is done entirely in content.css. This script's
 * only job is to reflect the toolbar toggle into the page by setting
 * <html data-srf-hh="on|off">, and to react when the toggle changes so the
 * strip reveals/hides instantly without a reload.
 *
 * Runs at document_start in Chrome, Firefox and Safari.
 */
(function () {
  "use strict";

  var api = (typeof browser !== "undefined" && browser.storage) ? browser : chrome;
  var STORAGE_KEY = "hideHighlights";
  var ROOT_ATTR = "data-srf-hh";

  function apply(enabled) {
    var root = document.documentElement;
    if (root) root.setAttribute(ROOT_ATTR, enabled ? "on" : "off");
  }

  function readSetting(cb) {
    try {
      var maybePromise = api.storage.local.get({ [STORAGE_KEY]: true });
      if (maybePromise && typeof maybePromise.then === "function") {
        maybePromise.then(function (res) {
          cb(res[STORAGE_KEY] !== false);
        });
        return;
      }
    } catch (e) {
      /* fall through to callback form */
    }
    api.storage.local.get({ [STORAGE_KEY]: true }, function (res) {
      cb(res[STORAGE_KEY] !== false);
    });
  }

  // React to the toolbar toggle live, in every open SRF tab.
  if (api.storage && api.storage.onChanged) {
    api.storage.onChanged.addListener(function (changes, areaName) {
      if (areaName !== "local") return;
      if (!changes[STORAGE_KEY]) return;
      apply(changes[STORAGE_KEY].newValue !== false);
    });
  }

  // Apply ASAP (default = on) so the strip never flashes, then sync with storage.
  apply(true);
  readSetting(apply);
})();
