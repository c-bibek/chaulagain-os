// Chaulagain OS default desktop layout.
// Plasma runs this the first time a user logs in (when they have no layout yet).
//
//   Top:    menu bar - app launcher, the current app's menus, status icons, clock
//   Bottom: floating dock - app icons and the trash

// ---- Menu bar ----
const menuBar = new Panel;
menuBar.location = "top";
menuBar.height = Math.round(gridUnit * 1.8);
menuBar.floating = false;

menuBar.addWidget("org.kde.plasma.kickoff");
menuBar.addWidget("org.kde.plasma.appmenu");
menuBar.addWidget("org.kde.plasma.panelspacer");
menuBar.addWidget("org.kde.plasma.systemtray");
menuBar.addWidget("org.kde.plasma.digitalclock");

// ---- Dock ----
const dock = new Panel;
dock.location = "bottom";
dock.height = Math.round(gridUnit * 3.5);
dock.alignment = "center";
dock.lengthMode = "fit";
dock.floating = true;

const apps = dock.addWidget("org.kde.plasma.icontasks");
apps.currentConfigGroup = ["General"];
apps.writeConfig("launchers", [
    "preferred://filemanager",
    "preferred://browser",
    "applications:org.kde.discover.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop"
].join(","));

dock.addWidget("org.kde.plasma.marginsseparator");
dock.addWidget("org.kde.plasma.trash");
