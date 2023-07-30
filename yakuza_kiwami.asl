// Yakuza Kiwami (PC: Steam, M Store) autosplitter & load remover
// Autosplitter by ToxicTT (Discord: ToxicTT#4487)
// Load remover by DrTChops
// Refresh + M Store + Settings by PlayingLikeAss (aposteriorist on Github)

state("YakuzaKiwami", "Steam")
{
    byte loadState: 0x19D5050, 0x1E8, 0x4A0, 0x4A0, 0x310, 0x1EDC;
    // string25 gameState0 : 0x128DD50, 0xC8, 0x490, 0x72;
    // string25 gameState1 : 0x128DD50, 0xC8, 0x490, 0xBA;
    // string25 gameState2 : 0x128DD50, 0xC8, 0x490, 0x102;
    // string25 gameState3 : 0x128DD50, 0xC8, 0x490, 0x14A;
    // string25 gameState4 : 0x128DD50, 0xC8, 0x490, 0x192;
    // string25 gameState5 : 0x128DD50, 0xC8, 0x490, 0x1DA;
    string25 titleCard: 0x10D9410, 0x182;
    string30 hactName: 0x10D9678, 0x7EA;
    byte enemyCount: 0x1274F20, 0x3F8;
    short kiryuHP: 0x1296140, 0x1E0, 0xA1E;
}

state("YakuzaKiwami", "M Store")
{
    byte loadState: 0x1E46C50, 0x1E8, 0x4A0, 0x4A0, 0x310, 0x1EDC;
    string25 titleCard: 0x149C3E0, 0x182;
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
    }
}

startup
{
    vars.Splits = new HashSet<string>();
    vars.doSplit = false;

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
        settings.Add("h6216_mia_revive", true, "Finale: Jingu", "bosses");
        settings.Add("h6195_nishiki_fight_02", true, "Finale: Nishiki", "bosses");
}

update
{
    vars.doSplit = false;

    Func<string, bool> isRelevant = split => (split != null && settings.ContainsKey(split) && settings[split] && !vars.Splits.Contains(split));

    // Check if a particular boss QTE is happening / has happened, signalling us to track that fight's progress.
    // We'll also check against Kiryu's HP, because otherwise a Game Over would give a false positive.
    if (isRelevant(current.hactName) && current.enemyCount == 0 && current.kiryuHP > 0)
    {
        vars.Splits.Add(current.hactName);
        vars.doSplit = true;
    }

    // Check if a particular chapter title card is being displayed.
    else if (isRelevant(current.titleCard))
    {
        vars.Splits.Add(current.titleCard);
        vars.doSplit = true;
    }

}

start
{
   return current.titleCard == "2d_mn_syotitle_01.dds";
}

split
{
    return vars.doSplit;
}

isLoading
{
    return current.loadState == 1;
}

onReset
{
    vars.Splits.Clear();
    vars.doSplit = false;
}
