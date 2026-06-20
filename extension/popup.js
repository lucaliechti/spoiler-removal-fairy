/*
 * SpoilerRemovalFairy  (popup)
 * Reads/writes the single "hideHighlights" boolean. Content scripts in every
 * open SRF tab react instantly via storage.onChanged. UI strings come from
 * _locales via i18n (en / de / fr / it), following the browser UI language.
 */
(function () {
  "use strict";

  var api = (typeof browser !== "undefined" && browser.storage) ? browser : chrome;
  var STORAGE_KEY = "hideHighlights";

  function msg(key, fallback) {
    try {
      var m = api.i18n && api.i18n.getMessage(key);
      return m || fallback;
    } catch (e) {
      return fallback;
    }
  }

  // Localise every element tagged with data-i18n.
  document.querySelectorAll("[data-i18n]").forEach(function (el) {
    el.textContent = msg(el.dataset.i18n, el.textContent.trim());
  });

  var toggle = document.getElementById("toggle");
  var stateText = document.getElementById("state-text");

  function render(on) {
    toggle.checked = on;
    stateText.textContent = on ? msg("stateOn", "On") : msg("stateOff", "Off");
  }

  function get(cb) {
    try {
      var p = api.storage.local.get({ [STORAGE_KEY]: true });
      if (p && typeof p.then === "function") {
        p.then(function (r) {
          cb(r[STORAGE_KEY] !== false);
        });
        return;
      }
    } catch (e) {
      /* fall through */
    }
    api.storage.local.get({ [STORAGE_KEY]: true }, function (r) {
      cb(r[STORAGE_KEY] !== false);
    });
  }

  function set(value) {
    var obj = {};
    obj[STORAGE_KEY] = value;
    try {
      var p = api.storage.local.set(obj);
      if (p && typeof p.then === "function") return;
    } catch (e) {
      /* fall through */
    }
    api.storage.local.set(obj, function () {});
  }

  get(render);

  toggle.addEventListener("change", function () {
    var on = toggle.checked;
    render(on);
    set(on);
  });
})();
