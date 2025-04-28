// 龍が如く 見参!
// Like a Dragon: Kenzan!
// By PlayingLikeAss (aposteriorist on Github)

state("rpcs3") {}

// There's no support in LiveSplit for big endian memory values,
// so we have to do a lot of heavy lifting with delegates.
init
{
    Thread.Sleep(3000);

    // How we'll track splits.
    vars.Splits = new HashSet<string>();

    // The global pointer to CActionManager.
    // IntPtr ptr_ActionManager = new IntPtr(0x300000000 + vars.FlipEndian4(memory.ReadValue<uint>(new IntPtr(0x3103c6e1c))));
    IntPtr ptr_ActionManager = IntPtr.Zero;
    vars.InitPtr_ActionManager = (Action)(()
        => ptr_ActionManager = new IntPtr(0x300000000 + vars.FlipEndian4(memory.ReadValue<uint>(new IntPtr(0x3103c6e1c)))));
    // Convenience function for IGT for testing.
    // CSaveData static location is 1034e190, save file is +0x10, IGT is +0x80.
    // IntPtr ptr_IGT = new IntPtr(0x31034e220);
    // vars.IGT = (Func<uint>)(() => vars.FlipEndian4(memory.ReadValue<uint>(ptr_IGT)));

    // The action int essentially determines the tick speed of the IGT.
    // The value is at 0x18 in CActionManager stored as an int,
    // but we'll only take the final byte to skip endianness calculations.
    // IntPtr ptr_ActionInt = IntPtr.Add(ptr_ActionManager, 0x1b);
    IntPtr ptr_ActionInt = IntPtr.Zero;
    vars.InitPtr_ActionInt = (Action)(() => ptr_ActionInt = IntPtr.Add(ptr_ActionManager, 0x1b));
    vars.ActionInt = (Func<byte>)(() => memory.ReadValue<byte>(ptr_ActionInt));

    // We'll also check the fade state, just like in other games.
    IntPtr ptr_FadeCtrlState = new IntPtr(0x31030ebb0);
    vars.FadeCtrlState = (Func<byte>)(() => memory.ReadValue<byte>(ptr_FadeCtrlState));

    // Get the pointer to any action by ID.
    vars.GetAction = (Func<int, IntPtr>)(id => {
        IntPtr pActionPtr = IntPtr.Add(ptr_ActionManager, 0x1c8 + id * 4);
        if (pActionPtr == IntPtr.Zero) return IntPtr.Zero;

        IntPtr pAction = IntPtr.Add((IntPtr)0x300000000, (int)vars.FlipEndian4(memory.ReadValue<uint>(pActionPtr)));
        return pAction;
    });

    // Get CActionFighterManager (ID is 3)
    vars.GetActionFighterManager = (Func<IntPtr>)(() => vars.GetAction(3));

    // Get CActionTitle (ID is 57)
    vars.GetActionTitle = (Func<IntPtr>)(() => vars.GetAction(57));

    // Determine if a new game has been started.
    vars.Start = (Func<bool>)(() => {
        IntPtr ptrTitle = vars.GetActionTitle();
        return ptrTitle == IntPtr.Zero ? false : memory.ReadValue<bool>(IntPtr.Add(ptrTitle, 0x14B));
    });

    // The global pointer to CScenarioState.
    // IntPtr ptr_ScenarioState = new IntPtr(0x300000000 + vars.FlipEndian4(memory.ReadValue<uint>(new IntPtr(0x3103c5b10))));
    IntPtr ptr_ScenarioState = IntPtr.Zero;
    vars.InitPtr_ScenarioState = (Action)(()
        => ptr_ScenarioState = new IntPtr(0x300000000 + vars.FlipEndian4(memory.ReadValue<uint>(new IntPtr(0x3103c5b10)))));
    IntPtr ptr_NewScenarioStateCount = IntPtr.Add(ptr_ScenarioState, 3);    // byte only, use from zero otherwise
    IntPtr ptr_ScenarioStateEntries  = IntPtr.Add(ptr_ScenarioState, 4);

    // Get the number of new temp. states.
    vars.GetNewStateCount = (Func<byte>)(() => memory.ReadValue<byte>(ptr_NewScenarioStateCount));

    // Get the temp. state entry at an index.
    vars.GetStateEntry = (Func<int, Tuple<uint, uint, bool>>)(index => {
        int indexAdj = index * 12;
        uint category = vars.FlipEndian4(memory.ReadValue<uint>(IntPtr.Add(ptr_ScenarioStateEntries, indexAdj)));
        uint stateIndex = vars.FlipEndian4(memory.ReadValue<uint>(IntPtr.Add(ptr_ScenarioStateEntries, indexAdj + 4)));
        bool state = memory.ReadValue<bool>(IntPtr.Add(ptr_ScenarioStateEntries, indexAdj + 11));
        return new Tuple<uint, uint, bool>(category, stateIndex, state);
    });

    // Get a pointer to a fighter from FighterManager by index.
    vars.GetFighter = (Func<int, IntPtr>)(index => {
        IntPtr ptr_FighterManager = vars.GetActionFighterManager();
        return ptr_FighterManager == IntPtr.Zero
        ? new IntPtr(0x300000000
            + vars.FlipEndian4(memory.ReadValue<uint>(IntPtr.Add(ptr_FighterManager, 0xfc + index * 4))))
        : IntPtr.Zero;
    });

    // Get Kiryu's pointer.
    vars.GetKiryu = (Func<IntPtr>)(() => vars.GetFighter(0));

    // Get Kiryu's mode.
    vars.GetMode = (Func<IntPtr, int>)(pFighter => pFighter != IntPtr.Zero ? memory.ReadValue<byte>(IntPtr.Add(pFighter, 0xcb3)) : 0);

    /*
    // The bitarray for permanent scenario state entries is 0x190 into the save file.
    // Each category gets its own subarray 0x20 in length.
    IntPtr ptr_sdScenarioState = new IntPtr(0x31034e330);

    // Given category and state indices, check if the specified permanent state is set.
    vars.IsStateSet = (Func<int, int, bool>)((category, state) => {
        int blockAdj = (state >> 5) * 4;
        int byteAdj = 3 - (state >> 3) & 3;
        int bitAdj = state & 7;
        // print(String.Format("{0}, {1}, {2}", blockAdj, byteAdj, bitAdj));
        IntPtr ptr_State = IntPtr.Add(ptr_sdScenarioState, (category * 0x20 + blockAdj + byteAdj));
        return ((memory.ReadValue<byte>(ptr_State) >> bitAdj) & 1) == 1;
    });
    */

    vars.InitPointers = (Action)(() => {
        vars.InitPtr_ActionManager();
        vars.InitPtr_ActionInt();
        vars.InitPtr_ScenarioState();
    });

    vars.InitPointers();
}

startup
{
    vars.FlipEndian4 = (Func<uint, uint>)((value) => {
        return ((value & 0x000000ff) << 24) +
            ((value & 0x0000ff00) << 8) +
            ((value & 0x00ff0000) >> 8) +
            ((value & 0xff000000) >> 24);
    });

    // vars.old_IGT = 0;
    // vars.current_IGT = 0;

	settings.Add("CHAPTER", true, "Chapter End Splits");
        settings.Add("8-0", true, "Prologue", "CHAPTER");
        settings.Add("9-0", true, "Chapter 1: 宮本 武蔵", "CHAPTER");
        settings.Add("10-0", true, "Chapter 2: 関ヶ原の罠", "CHAPTER");
        settings.Add("11-0", true, "Chapter 3: 誓い", "CHAPTER");
        settings.Add("12-0", true, "Chapter 4: 新たな人生", "CHAPTER");
        settings.Add("13-0", true, "Chapter 5: 一両の願い", "CHAPTER");
        settings.Add("14-0", true, "Chapter 6: 吉岡道場", "CHAPTER");
        settings.Add("15-0", true, "Chapter 7: 炎上", "CHAPTER");
        settings.Add("16-0", true, "Chapter 8: 宝蔵院", "CHAPTER");
        settings.Add("17-0", true, "Chapter 9: 果し合い", "CHAPTER");
        settings.Add("18-0", true, "Chapter 10: 狸爺の依頼", "CHAPTER");
        settings.Add("19-0", true, "Chapter 11: 真実", "CHAPTER");

    settings.Add("FIGHT", false, "Fight Splits");
        settings.Add("7-15", false, "Tutorial I", "FIGHT");
        settings.Add("7-28", false, "Tutorial II", "FIGHT");
        settings.Add("8-30", false, "Marume", "FIGHT");
        settings.Add("9-11", false, "Marume II", "FIGHT");
        settings.Add("10-14", false, "A Moonlit Fight", "FIGHT");
        settings.Add("11-3", false, "Ch.4 Bounty Hunters", "FIGHT");
        settings.Add("12-44", false, "Shogi Showdown", "FIGHT");
        settings.Add("12-62", false, "Greatsword Tutorial", "FIGHT");
        settings.Add("12-74", false, "Shishido Baiken", "FIGHT");
        settings.Add("13-26", false, "Ueda Ryohei", "FIGHT");
        settings.Add("13-30", false, "Yoshioka Seijuro", "FIGHT");
        settings.Add("14-7", false, "Ito Ittosai", "FIGHT");
        settings.Add("15-26", false, "Hozoin In'ei", "FIGHT");
        settings.Add("15-34", false, "Tachibana Benimaru", "FIGHT");
        settings.Add("15-36", false, "Kenzen", "FIGHT");
        settings.Add("15-38", false, "Hozoin Inshun", "FIGHT");
        settings.Add("16-26", false, "Yoshioka Seijuro II", "FIGHT");
        settings.Add("16-40", false, "The Yoshioka 100", "FIGHT");
        settings.Add("16-58", false, "Gion Touji", "FIGHT");
        settings.Add("17-26", false, "Shogi Showdown II", "FIGHT");
        settings.Add("17-72", false, "Shishido Baiken II", "FIGHT");
        settings.Add("18-25", false, "Yagyu Village Hell Fight", "FIGHT");
        settings.Add("18-33", false, "Marume III", "FIGHT");
        settings.Add("19-30", false, "Sasaki Kojiro", "FIGHT");
        settings.Add("19-43", false, "Yellow Oni", "FIGHT");
        settings.Add("19-49", false, "White Oni", "FIGHT");
        settings.Add("19-60", false, "Black Oni", "FIGHT");
        settings.Add("19-67", false, "Blue Oni", "FIGHT");
        settings.Add("19-75", false, "Red Oni", "FIGHT");
        settings.Add("FINAL BOSS", false, "Tenkai", "FIGHT");
        // settings.Add("", false, "", "FIGHT");

    settings.Add("OTHER", false, "Other Splits");
        settings.Add("11-9", false, "Musashi's New Clothes", "OTHER");
        settings.Add("83-8", false, "Drunk Sword", "OTHER");
        settings.Add("13-6", false, "Gion Touji Gets Paid", "OTHER");
        settings.Add("13-17", false, "Dango Delivery", "OTHER");
        settings.Add("13-22", false, "Scarecrow Slashing", "OTHER");
        settings.Add("19-27", false, "Boat to Ganryu Island", "OTHER");
        settings.Add("19-36", false, "Entering the Castle", "OTHER");

    // Track if we're in the final boss. Should be fine even on game over.
    // (It won't be fine on game over for Legend, but let's be real, you're going to reset.)
    vars.InFinalBoss = false;
}

// update
// {
//     vars.old_IGT = vars.current_IGT;
//     vars.current_IGT = vars.IGT();
// }

start
{
    return vars.Start();
}

isLoading
{
    return vars.ActionInt() == 0 && vars.FadeCtrlState() == 2;
}

split
{
    // Iterate over all new states.
    int newStateCount = vars.GetNewStateCount();
    for (int i = 0; i < newStateCount; i++)
    {
        Tuple<uint, uint, bool> entry = vars.GetStateEntry(i);
        if (entry.Item3)
        {
            string s = string.Format("{0}-{1}", entry.Item1, entry.Item2);
            if (!vars.Splits.Contains(s))
            {
                vars.Splits.Add(s);

                if (entry.Item1 == 19 && entry.Item2 == 81)
                {
                    vars.InFinalBoss = true;
                    print("In Final Boss");
                }
                print(s);
                return settings[s]; // We're assuming that two splitting states will not simultaneously occur.
            }
        }
    }

    // If we're in the final boss, and Kiryu is in HACTED mode, then we're at the end.
    // (I don't think Tenkai has any heat actions)
    if (vars.InFinalBoss && vars.GetMode(vars.GetKiryu()) == 0x10)
    {
        // We're about three frames early, so we'll sleep first.
        // Forgive me my transgressions.
        Thread.Sleep(100);
        vars.InFinalBoss = false;
        print("Final Boss Split");
        return settings["FINAL BOSS"];
    }
}

onReset
{
    vars.InitPointers();
    vars.Splits.Clear();
    vars.InFinalBoss = false;
}