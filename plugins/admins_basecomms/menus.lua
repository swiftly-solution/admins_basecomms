function GenerateMenu()
    menus:Unregister("admin_comms")

    menus:Register("admin_comms", FetchTranslation("admins.adminmenu.comms.title"), tostring(config:Fetch("admins.amenucolor")), {
        { FetchTranslation("admins.adminmenu.addmute"), "sw_addmutemenu" },
        { FetchTranslation("admins.adminmenu.addgag"), "sw_addgagmenu" },
        { FetchTranslation("admins.adminmenu.addsilence"), "sw_addsilencemenu" },
    })
end
