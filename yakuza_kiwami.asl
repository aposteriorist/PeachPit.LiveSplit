// Yakuza Kiwami (PC: Steam, M Store) autosplitter & load remover
// Autosplitter by ToxicTT (Discord: ToxicTT#4487)
// Load remover by DrTChops
// Refresh + M Store + Settings by PlayingLikeAss (aposteriorist on Github)

state("YakuzaKiwami", "Steam")
{
    byte loadState: 0x19D5050, 0x2D54;
    string25 titleCard: 0x10D9410, 0x182;
    string40 hactName: 0x10D9678, 0x7EA;
    short kiryuHP: 0x10DD520, 0x4C0, 0xD58, 0x10, 0x28, 0x16;
    byte enemyCount: 0x1274F20, 0x3F8;
}

state("YakuzaKiwami", "M Store")
{
    byte loadState: 0x1E46C50, 0x2D54;
    string25 titleCard: 0x149C3E0, 0x182;
    string40 hactName: 0x149C648, 0x7EA;
    short kiryuHP: 0x14AAF20, 0x4C0, 0xD58, 0x10, 0x28, 0x16;
    byte enemyCount: 0x1666F40, 0x3F8;
}

state("YakuzaKiwami", "GOG")
{
    byte loadState: 0x197BAD0, 0x2D54;
    string25 titleCard: 0x1080010, 0x182;
    string40 hactName: 0x1080278, 0x7EA;
    short kiryuHP: 0x1084120, 0x4C0, 0xD58, 0x10, 0x28, 0x16;
    byte enemyCount: 0x121BB20, 0x3F8;
}

init
{
    switch(modules.First().ModuleMemorySize)
    {
        case 31207424:
            version = "Steam";
            break;
        case 36208640:
            version = "M Store";
            break;
        case 30654464:
            version = "GOG";
            break;
    }
}

startup
{
    vars.Splits = new HashSet<string>();
    vars.boss = "";
    vars.isRelevant = null; // In onStart, this will store our delegate.

    settings.Add("chapters", true, "Chapter End Splits");
        settings.Add("2d_mn_syotitle_02.dds", true, "Chapter 1: Fate of a Kinslayer", "chapters");
        settings.Add("2d_mn_syotitle_03.dds", true, "Chapter 2: 10 Years Gone", "chapters");
        settings.Add("2d_mn_syotitle_04.dds", true, "Chapter 3: Funeral of Fists", "chapters");
        settings.Add("2d_mn_syotitle_05.dds", true, "Chapter 4: An Encounter", "chapters");
        settings.Add("2d_mn_syotitle_06.dds", true, "Chapter 5: Purgatory", "chapters");
        settings.Add("2d_mn_syotitle_07.dds", true, "Chapter 6: Father and Child", "chapters");
        settings.Add("2d_mn_syotitle_08.dds", true, "Chapter 7: The Dragon and the Koi", "chapters");
        settings.Add("2d_mn_syotitle_09.dds", true, "Chapter 8: The Scheme", "chapters");
        settings.Add("2d_mn_syotitle_10.dds", true, "Chapter 9: The Rescue", "chapters");
        settings.Add("2d_mn_syotitle_11.dds", true, "Chapter 10: Shape of Love", "chapters");
        settings.Add("2d_mn_syotitle_12.dds", true, "Chapter 11: Honor and Humanity", "chapters");
        settings.Add("2d_mn_syotitle_13.dds", true, "Chapter 12: Reunited", "chapters");

    settings.Add("bosses", true, "Boss Splits");
        settings.Add("h6162_liu_pick_sword", false, "Ch. 9: Lau Ka Long", "bosses");
        settings.Add("h6140_majima_floorbreak", false, "Ch. 11: Majima", "bosses");
        settings.Add("h6216_mia_revive", false, "Finale: Jingu", "bosses");
        settings.Add("h6195_nishiki_fight_02", true, "Finale: Nishiki", "bosses");
            settings.Add("timerend", false, "If checked, the Nishiki split will forcibly stop the timer (by splitting repeatedly if extra splits remain).", "h6195_nishiki_fight_02");
}

start
{
   return current.titleCard == "2d_mn_syotitle_01.dds";
}

onStart
{
    // In the startup event, settings is a reference to an ASLSettingsBuilder, so it's useless.
    // This is the earliest time we can grab settings as an ASLSettingsReader.
    if (vars.isRelevant == null)
    {
        Func<string, bool> isRelevant = split => (split != null && settings.ContainsKey(split) && settings[split] && !vars.Splits.Contains(split));
        vars.isRelevant = isRelevant;
    }
}

split
{
    // Check if we should start tracking a fight, based on relevant hacts.
    if (vars.isRelevant(current.hactName))
        vars.boss = current.hactName;

    // If we're tracking a fight:
    if (vars.boss != "")
    {
        // Check against Kiryu's HP, because otherwise a Game Over would give a false positive.
        if (current.kiryuHP < 1)
        {
            vars.boss = "";
        }
        // No more enemies means we're done.
        else if (current.enemyCount == 0)
        {
            // Split forever on the final boss if that setting is set. Otherwise, split once.
            if (vars.boss != "h6195_nishiki_fight_02" || !settings["timerend"])
            {
                vars.Splits.Add(vars.boss);
                vars.boss = "";
            }

            return true;
        }
    }

    // Otherwise, split if a particular chapter title card is being displayed.
    else if (vars.isRelevant(current.titleCard))
    {
        vars.Splits.Add(current.titleCard);
        return true;
    }
}

isLoading
{
    return current.loadState == 1;
}

onReset
{
    vars.Splits.Clear();
    vars.boss = "";
}
