// Yakuza 0 (PC: Steam, M Store, GOG) autosplitter & load remover
// Autosplitter by ToxicTT (Discord: ToxicTT#4487)
// Thank you rythin_sr for the advice, Drake_Shadow and JustSayKuro for initial testing.
// Description: https://pastebin.com/uTDJEGCk
// Load remover by DrTChops
// M Store, GOG, boss splits, auto-start/reset/end, loading bugfix by PlayingLikeAss (aposteriorist on Github)

state("Yakuza0", "Steam")
{
    string25 titleCard: 0x1163EF0, 0x182;
    string40 location: 0x1163F28, 0x150, 0x18, 0x50;
    string40 hactName: 0x1164148, 0x7FA;
    byte QTEArrayIDX2: 0x1164148, 0x13C4;
    byte startSelect:  0x1164688, 0xC0, 0x130, 0x178, 0x8, 0x224;
    byte startIsValid: 0x1164688, 0xC0, 0x130, 0x178, 0x8, 0x22C;
    short protagHP:  0x11690C8, 0x4C0, 0xD58, 0x10, 0x28, 0x16;
    byte enemyCount: 0x1300768, 0x3F8;
    string25 gameState: 0x1305FC8, 0x50, 0x6E2;
    int loadState: 0x1A696C0, 0x0, 0x2D54;
}

state("Yakuza0", "M Store")
{
    string40 location: 0x14EB6C8, 0x150, 0x18, 0x50;
    string40 hactName: 0x14EB8E8, 0x7EA;
    byte QTEArrayIDX2: 0x14EB8E8, 0x130C;
    byte startSelect:  0x14EBE28, 0xC0, 0x130, 0x178, 0x8, 0x224;
    int startIsValid:  0x14EBE28, 0xC0, 0x130, 0x178, 0x8, 0x22C;
    short protagHP:  0x14FA128, 0x4C0, 0xD58, 0x10, 0x28, 0x16;
    byte enemyCount: 0x16AE2D8, 0x3F8;
    string25 gameState: 0x16C1410, 0x60, 0x6E2;
    int loadState: 0x1E45740, 0x0, 0x2D54;
}

state("Yakuza0", "GOG")
{
    string40 location: 0x1108BA8, 0x150, 0x18, 0x50;
    string40 hactName: 0x1108DC8, 0x7FA;
    byte QTEArrayIDX2: 0x1108DC8, 0x13C4;
    byte startSelect:  0x1109308, 0xC0, 0x130, 0x178, 0x8, 0x224;
    int startIsValid:  0x1109308, 0xC0, 0x130, 0x178, 0x8, 0x22C;
    short protagHP:  0x110DD48, 0x4C0, 0xD58, 0x10, 0x28, 0x16;
    byte enemyCount: 0x12A53E8, 0x3F8;
    string25 gameState: 0x12AAC48, 0x50, 0x6E2;
    int loadState: 0x1A0E140, 0x0, 0x2D54;
}

init
{
    switch(modules.First().ModuleMemorySize)
    {
        case 31207424:
            version = "Steam";
            break;
        case 36274176:
            version = "M Store";
            break;
        case 31997952:
            version = "GOG";
            break;
    }
}

startup
{
    vars.Splits = new HashSet<string>();
    vars.boss = "";
    vars.chapter = 1;
    vars.postEmptyLocation = "";
    vars.doSplit = false;

    settings.Add("Chapters", true, "Chapter End Splits");
        settings.Add("NewSplits", false, "Split on chapter cards instead of chapter result screens", "Chapters");
            settings.Add("2d_mn_syotitle_02.dds", true, "Chapter 1: Bound by Oath", "NewSplits");
            settings.Add("2d_mn_syotitle_03.dds", true, "Chapter 2: The Broker in the Shadows", "NewSplits");
            settings.Add("2d_mn_syotitle_04.dds", true, "Chapter 3: A Gilded Cage", "NewSplits");
            settings.Add("2d_mn_syotitle_05.dds", true, "Chapter 4: Proof of Resolve", "NewSplits");
            settings.Add("2d_mn_syotitle_06.dds", true, "Chapter 5: An Honest Living", "NewSplits");
            settings.Add("2d_mn_syotitle_07.dds", true, "Chapter 6: The Yakuza Way", "NewSplits");
            settings.Add("2d_mn_syotitle_08.dds", true, "Chapter 7: A Dark Escape", "NewSplits");
            settings.Add("2d_mn_syotitle_09.dds", true, "Chapter 8: Tug of War", "NewSplits");
            settings.Add("2d_mn_syotitle_10.dds", true, "Chapter 9: Ensnared", "NewSplits");
            settings.Add("2d_mn_syotitle_11.dds", true, "Chapter 10: A Man's Worth", "NewSplits");
            settings.Add("2d_mn_syotitle_12.dds", true, "Chapter 11: A Murky Riverbed", "NewSplits");
            settings.Add("2d_mn_syotitle_13.dds", true, "Chapter 12: Den of Desires", "NewSplits");
            settings.Add("2d_mn_syotitle_14.dds", true, "Chapter 13: Crime & Punishment", "NewSplits");
            settings.Add("2d_mn_syotitle_15.dds", true, "Chapter 14: Unwavering Bonds", "NewSplits");
            settings.Add("2d_mn_syotitle_16.dds", true, "Chapter 15: Scattered Light", "NewSplits");
            settings.Add("2d_mn_syotitle_17.dds", true, "Chapter 16: Proof of Love", "NewSplits");

    settings.Add("Bosses", true, "Boss Splits");
        settings.Add("h23250_kuze_rush", false, "Ch.1: Kuze", "Bosses");
        settings.Add("h23285_ri_godhand_short", false, "Ch.4: Massive Man", "Bosses");
        settings.Add("h23280_ri_godhand", false, "Ch.7: Wen Hai Lee", "Bosses");
        settings.Add("h23290_kishitani_dosu", false, "Ch.8: Nishitani", "Bosses");
        settings.Add("h23251_kuze_rush_01", false, "Ch.9: Kuze", "Bosses");
        settings.Add("h23291_kishitani_dosu_01", false, "Ch.11: Nishitani", "Bosses");
        settings.Add("h23360_sera_hact", false, "Ch.12: Sera", "Bosses");
        settings.Add("h23380_kashiwagi", false, "Ch.15: Kashiwagi", "Bosses");
        settings.Add("h23281_nishiki_bin_hact", false, "Ch.15: Nishiki", "Bosses");
        settings.Add("h23370_kuze_hact_naguri", false, "Finale: Kuze", "Bosses");
        settings.Add("h23390_awano", false, "Finale: Awano", "Bosses");
        settings.Add("h23420_raw_gs_end", false, "Finale: Lao Gui", "Bosses");
        settings.Add("h23460_shibusawa_last", true, "Finale: Shibusawa", "Bosses");

    settings.Add("Midsplits", false, "Mid-Chapter Splits (check tooltips)");

    settings.Add("ch1", false, "Chapter 1", "Midsplits");
    settings.Add("ch1A", false, "Visited Dojima Family HQ", "ch1");
    settings.SetToolTip("ch1A", "Splits when you are back in Kamurocho and about to fight Bruno.");
    settings.Add("ch1B", false, "Arrived at Dojima Family HQ to fight", "ch1");
    settings.SetToolTip("ch1B", "Splits on the first cutscene of the HQ.");

    settings.Add("ch2", false, "Chapter 2", "Midsplits");
    settings.Add("ch2A", false, "Visited Kiryu's Apartment", "ch2");
    settings.SetToolTip("ch2A", "Splits when you are back in Kamurocho, Hotel District.");
    settings.Add("ch2B", false, "Arrived in Public Park 3 to homeless men", "ch2");
    settings.SetToolTip("ch2B", "Splits right as you step into that little park area.");

    settings.Add("ch3", false, "Chapter 3", "Midsplits");
    settings.Add("ch3A", false, "Out of Cabaret Grand", "ch3");
    settings.SetToolTip("ch3A", "Splits after you first leave your cabaret.");
    settings.Add("ch3B", false, "Out of Club Odyssey", "ch3");
    settings.SetToolTip("ch3B", "Splits when you leave Odyssey club and about to talk on the payphone.");

    settings.Add("ch4", false, "Chapter 4", "Midsplits");
    settings.Add("ch4A", false, "Out of Maharaja", "ch4");
    settings.SetToolTip("ch4A", "Splits when you leave Maharaja and about to fight outside.");
    settings.Add("ch4B", false, "Out of Hogushi Kaikan Massage", "ch4");
    settings.SetToolTip("ch4B", "Splits when you leave the clinic and start looking for Makoto.");

    settings.Add("ch5", false, "Chapter 5", "Midsplits");
    settings.Add("ch5A", false, "Out of Serena", "ch5");
    settings.SetToolTip("ch5A", "Splits once you exit out of Serena bar, before the fight");

    settings.Add("ch6", false, "Chapter 6", "Midsplits");
    settings.Add("ch6A", false, "Out of Komurocho to Kiryu's Apartment", "ch6");
    settings.SetToolTip("ch6A", "Splits when you arrive in the area near Kiryu's Apartment.");
    settings.Add("ch6B", false, "Into the Sewer", "ch6");
    settings.SetToolTip("ch6B", "Splits when you step into the sewers.");

    settings.Add("ch7", false, "Chapter 7", "Midsplits");
    settings.Add("ch7A", false, "Bought takoyaki", "ch7");
    settings.SetToolTip("ch7A", "Splits after you bought takoyaki and heading back to Makoto.");
    settings.Add("ch7B", false, "Went through the hidden door in clinic", "ch7");
    settings.SetToolTip("ch7B", "Splits when you stepped through the hidden door in Hogushi Kaikan Massage and appeared in the back alley.");

    settings.Add("ch8", false, "Chapter 8", "Midsplits");
    settings.Add("ch8A", false, "Out of Cabaret Grand", "ch8");
    settings.SetToolTip("ch8A", "Splits when you exit out of cabaret after Nishitani fight.");
    settings.Add("ch8B", false, "Reached the 2nd stealth section", "ch8");
    settings.SetToolTip("ch8B", "Splits when you get to Shofukucho street, the 2nd stealth section.");

    settings.Add("ch9", false, "Chapter 9", "Midsplits");
    settings.Add("ch9A", false, "Out of Serena", "ch9");
    settings.SetToolTip("ch9A", "Splits when you done fighting in Serena and exit through the backdoor.");

    settings.Add("ch10", false, "Chapter 10", "Midsplits");
    settings.Add("ch10A", false, "Arrived at Tojo Clan HQ", "ch10");
    settings.SetToolTip("ch10A", "Splits when you arrive at Tojo Clan HQ.");
    settings.Add("ch10B", false, "Out of Tojo Clan HQ (Pier cutscene)", "ch10");
    settings.SetToolTip("ch10B", "Splits once you escape from Tojo Clan HQ, on pier cutscene.");

    settings.Add("ch11", false, "Chapter 11", "Midsplits");
    settings.Add("ch11A", false, "Out of colosseum", "ch11");
    settings.SetToolTip("ch11A", "Splits once you are back at the bridge after The Bed of Styx.");

    // no splits for ch 12
    // short chapter, all in the same location

    settings.Add("ch13", false, "Chapter 13", "Midsplits");
    settings.Add("ch13A", false, "Got to Benten Inn", "ch13");
    settings.SetToolTip("ch13A", "Splits when Oda and Kiryu reach Benten Inn, right before the chase begins.");
    settings.Add("ch13B", false, "Got to Building Under Construction", "ch13");
    settings.SetToolTip("ch13B", "Splits once you get to the construction site.");

    settings.Add("ch14", false, "Chapter 14", "Midsplits");
    settings.Add("ch14A", false, "Got to Crescendo Building", "ch14");
    settings.SetToolTip("ch14A", "Splits once you get to the door of Crescendo Building.");

    settings.Add("ch15", false, "Chapter 15", "Midsplits");
    settings.Add("ch15A", false, "Got to rooftop with Kashiwagi", "ch15");
    settings.SetToolTip("ch15A", "Splits once get to the rooftop of Kazama HQ.");
    settings.Add("ch15B", false, "Back on the streets after Kashiwagi fight", "ch15");
    settings.SetToolTip("ch15B", "Splits after the Kashiwagi fight, on Nakamichi Alley.");
    settings.Add("ch15C", false, "Out of Serena", "ch15");
    settings.SetToolTip("ch15C", "Splits after Nishiki fight, on Tenkaichi St.");

    settings.Add("ch16", false, "Chapter 16", "Midsplits");
    settings.Add("ch16A", false, "Reached Children's Park with Makoto", "ch16");
    settings.SetToolTip("ch16A", "Splits when cutscene in Children's Park starts.");
    settings.Add("ch16B", false, "Reached Sebastian Building", "ch16");
    settings.SetToolTip("ch16B", "Splits once you reach Sebastian Building.");

    settings.Add("ch17", false, "Chapter 17", "Midsplits");
    settings.Add("ch17A", false, "Out of Kamurocho", "ch17");
    settings.SetToolTip("ch17A", "Splits when you get to the office with Majima after leaving Kamurocho.");
    settings.Add("ch17B", false, "Finished fighting through the Consortium Ship", "ch17");
    settings.SetToolTip("ch17B", "Splits once you done going through the ship and switched to Majima.");
    settings.Add("ch17C", false, "Reached the top floor of Dojima HQ", "ch17");
    settings.SetToolTip("ch17C", "Splits once you enter the cutscene with Awano.");
    settings.Add("ch17D", false, "Finished with Dojima HQ fights", "ch17");
    settings.SetToolTip("ch17D", "Splits once you're done fighting at Dojima HQ and transitioned to the Consortium Ship.");
}

update
{
    vars.doSplit = false;

    if (current.location == "" && old.location != "")
    {
        vars.postEmptyLocation = old.location;
    }

    // If we're not currently tracking a fight:
    if (vars.boss == "" && settings["Bosses"])
    {
        // Check if we should start tracking a fight, based on relevant hacts.
        if (current.hactName != null && settings.ContainsKey(current.hactName) && settings[current.hactName] && !vars.Splits.Contains(current.hactName))
        {
            vars.boss = current.hactName;
        }
    }

    // If we're now tracking a fight:
    if (vars.boss != "")
    {
        // Check against the current character's HP, because otherwise a Game Over would give a false positive.
        if (current.protagHP < 1)
        {
            vars.boss = "";
        }

        // If it's Shibusawa:
        else if (vars.boss == "h23460_shibusawa_last" && current.QTEArrayIDX2 != 2 && old.QTEArrayIDX2 == 2)
        {
            if (current.QTEArrayIDX2 == 1 || current.protagHP > 50)
            {
                vars.doSplit = true;
                vars.Splits.Add(vars.boss);
            }

            vars.boss = "";
        }

        // Otherwise, no more enemies means we're done.
        else if (current.enemyCount == 0)
        {
            vars.doSplit = true;
            vars.Splits.Add(vars.boss);
            vars.boss = "";
        }
    }

    // Is there a chapter split?
    else if (settings["Chapters"] && settings["NewSplits"] && current.titleCard != old.titleCard && current.titleCard.StartsWith("2d_mn_syotitle"))
    {
        vars.doSplit == settings.ContainsKey(current.titleCard) && settings[current.titleCard];
        vars.chapter++;
    }

    // Is there a chapter split (legacy option)?
    else if (settings["Chapters"] && !settings["NewSplits"] && current.gameState != old.gameState && current.gameState == "pjcm_result.sbb")
    {
        vars.doSplit == true;
        vars.chapter++;
    }

    // Is there a mid-chapter split?
    else if (settings["Midsplits"])
    {
        if (vars.chapter == 1)
        {
            if (current.location == "Nakamichi St. Entrance" && vars.postEmptyLocation == "Dojima Family HQ")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch1A"];
            }
            else if (current.location == "Dojima Family HQ" && vars.postEmptyLocation == "Tenkaichi St. Entrance")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch1B"];
            }
        }
        else if (vars.chapter == 2)
        {
            if (current.location == "Hotel District" && vars.postEmptyLocation == "Near Kiryu's Apartment")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch2A"];
            }
            else if (current.location == "Public Park 3" && old.location == "Tenkaichi Alley" && vars.postEmptyLocation != "Public Park 3")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch2B"];
            }
        }
        else if (vars.chapter == 3)
        {
            if (current.location == "Sotenbori St. West" && vars.postEmptyLocation == "Cabaret Grand")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch3A"];
            }
            else if (current.location == "Shofukucho South" && vars.postEmptyLocation == "Odyssey")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch3B"];
            }
        }
        else if (vars.chapter == 4)
        {
            if (current.location == "Shofukucho East" && vars.postEmptyLocation == "Maharaja Sotenbori")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch4A"];
            }
            else if (current.location == "Shofukucho South" && vars.postEmptyLocation == "Hogushi Kaikan Massage")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch4B"];
            }
        }
        else if (vars.chapter == 5)
        {
            if (current.location == "Serena Backlot" && vars.postEmptyLocation == "Serena")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch5A"];
            }
        }
        else if (vars.chapter == 6)
        {
            if (current.location == "Near Kiryu's Apartment" && vars.postEmptyLocation == "Hotel District")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch6A"];
            }
            else if (current.location == "Sewer" && vars.postEmptyLocation == "Asia")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch6B"];
            }
        }
        else if (vars.chapter == 7)
        {
            if (current.location != "Magutako" && old.location == "Magutako" && vars.postEmptyLocation != "Magutako")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch7A"];
            }
            else if (current.location == "Hoganji Yokocho" && vars.postEmptyLocation == "Hogushi Kaikan Massage")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch7B"];
            }
        }
        else if (vars.chapter == 8)
        {
            if (current.location == "Sotenbori St. West" && vars.postEmptyLocation == "Cabaret Grand")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch8A"];
            }
            else if (current.location == "Shofukucho" && vars.postEmptyLocation == "Odyssey's Warehouse")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch8B"];
            }
        }
        else if (vars.chapter == 9)
        {
            if (current.location == "Serena Backlot" && vars.postEmptyLocation == "Serena")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch9A"];
            }
        }
        else if (vars.chapter == 10)
        {
            if (current.location == "Tojo Clan Headquarters" && vars.postEmptyLocation == "West Park")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch10A"];
            }
            else if (current.location == "Pier" && vars.postEmptyLocation == "Tojo Clan Headquarters")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch10B"];
            }
        }
        else if (vars.chapter == 11)
        {
            if (current.location == "Bishamon Bridge" && vars.postEmptyLocation == "The Bed of Styx")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch11A"];
            }
        }
        else if (vars.chapter == 13)
        {
            if (current.location == "Benten Inn" && vars.postEmptyLocation == "CAL Videos")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch13A"];
            }
            else if (current.location == "Building Under Construction" && vars.postEmptyLocation == "Benten Inn")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch13B"];
            }
        }
        else if (vars.chapter == 14)
        {
            if (current.location == "Crescendo Building" && vars.postEmptyLocation == "West Park")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch14A"];
            }
        }
        else if (vars.chapter == 15)
        {
            if (current.location == "Certain Rooftop" && vars.postEmptyLocation == "Tenkaichi St.")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch15A"];
            }
            else if (current.location == "Nakamichi Alley" && vars.postEmptyLocation == "Certain Rooftop")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch15B"];
            }
            else if (current.location == "Tenkaichi St." && vars.postEmptyLocation == "Serena")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch15C"];
            }
        }
        else if (vars.chapter == 16)
        {
            if (current.location == "Children's Park" && old.location == "Theater Square" && vars.postEmptyLocation == "The Empty Lot")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch16A"];
            }
            else if (current.location == "Sebastian Building" && vars.postEmptyLocation == "Park Blvd.")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch16B"];
            }
        }
        else if (vars.chapter == 17)
        {
            if (current.location == "Sagawa's Secret Office" && vars.postEmptyLocation == "Tenkaichi St. Entrance")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch17A"];
            }
            else if (current.location == "Dojima Family HQ" && vars.postEmptyLocation == "Nikkyo Consortium Ship")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch17B"];
            }
            else if (current.location == "Dojima Family HQ Top Floor" && vars.postEmptyLocation == "Dojima Family HQ")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch17C"];
            }
            else if (current.location == "Nikkyo Consortium Ship" && vars.postEmptyLocation == "Dojima Family HQ Top Floor")
            {
                vars.postEmptyLocation = current.location;
                vars.doSplit = settings["ch17D"];
            }
        }
    }
}

start
{
    return current.startSelect == 0 && old.startSelect == 1 && current.startIsValid != 0;
}

onStart
{
    vars.Splits.Clear();
    vars.boss = "";
    vars.chapter = settings["NewSplits"] ? 0 : 1;
    vars.postEmptyLocation = "";
}

split
{
    return vars.doSplit;
}

isLoading
{
    return current.loadState == 1;
}

reset
{
    return current.gameState == "pjcm_title_ps3.sbb" && current.gameState != old.gameState;
}
