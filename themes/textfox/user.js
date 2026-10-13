// userchrome.css usercontent.css activate
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Fill SVG Color
user_pref("svg.context-properties.content.enabled", true);

// CSS's `:has()` selector 
user_pref("layout.css.has-selector.enabled", true);

// Allow unsigned add-ons/themes (e.g. local themes)
user_pref("xpinstall.signatures.required", false);

// Select the Cosmic Purple theme
user_pref("extensions.activeThemeID", "cosmic-purple@lainos.local");
