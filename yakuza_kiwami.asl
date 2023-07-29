// Yakuza Kiwami (PC, Steam) autosplitter & load remover
// Autosplitter by ToxicTT (Discord: ToxicTT#4487)
// Load remover by DrTChops
// Refresh + M Store by PlayingLikeAss (aposteriorist on Github)

state("YakuzaKiwami", "Steam")
{
    int loadState: 0x19D5050, 0x1E8, 0x4A0, 0x4A0, 0x310, 0x1EDC;
    // string25 gameState0 : 0x128DD50, 0xC8, 0x490, 0x72;
    // string25 gameState1 : 0x128DD50, 0xC8, 0x490, 0xBA;
    // string25 gameState2 : 0x128DD50, 0xC8, 0x490, 0x102;
    // string25 gameState3 : 0x128DD50, 0xC8, 0x490, 0x14A;
    // string25 gameState4 : 0x128DD50, 0xC8, 0x490, 0x192;
    // string25 gameState5 : 0x128DD50, 0xC8, 0x490, 0x1DA;
    string25 chapterCard: 0x10D9410, 0x182;
    string30 hactName: 0x10D9678, 0x7EA;
    byte enemyCount: 0x1274F20, 0x3F8;
    short kiryuHP: 0x1296140, 0x1E0, 0xA1E;

}

state("YakuzaKiwami", "M Store")
{
    int loadState: 0x1E46C50, 0x1E8, 0x4A0, 0x4A0, 0x310, 0x1EDC;
    string25 chapterCard: 0x149C3E0, 0x182;
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
    vars.isLoading = false;
    vars.doSplit = false;
    vars.doStart = false;
    vars.prevChapterDisplay = false;
    vars.nishiki = false;
}

update
{
    vars.isLoading = current.loadState == 1;
    vars.doSplit = false;
    vars.doStart = false;

    // The run doesn't end after this QTE if Nishiki's health is high enough, so here we'll simply store whether or not the QTE has begun.
    // We'll also check against Kiryu's HP, because otherwise a Game Over will give a false positive.
    vars.nishiki = (vars.nishiki || current.hactName == "h6195_nishiki_fight_02") && current.kiryuHP > 0;

    bool chapterDisplay = current.chapterCard != null && current.chapterCard.StartsWith("2d_mn_syotitle");

    if (chapterDisplay && !vars.prevChapterDisplay
     || vars.nishiki && current.enemyCount == 0)
    {
        vars.doSplit = true;
        vars.doStart = true;
    }

    vars.prevChapterDisplay = chapterDisplay;
}

start
{
    return vars.doStart;
}

split
{
    return vars.doSplit;
}

isLoading
{
    return vars.isLoading;
}

onReset
{
    vars.isLoading = false;
    vars.doSplit = false;
    vars.doStart = false;
    vars.prevChapterDisplay = false;
    vars.nishiki = false;
}
