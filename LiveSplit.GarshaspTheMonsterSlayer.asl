state("Garshasp")
{
    int Stopwatch: "Zorvan_t.dll", 0xBD173C;
    byte Loadboy: -2498633;
}

onStart
{
    timer.IsGameTimePaused = true;
}

start
{
    return current.Stopwatch != old.Stopwatch;
}

isLoading
{
    return current.Loadboy != 0 && current.Stopwatch == old.Stopwatch;
}

exit
{
    timer.IsGameTimePaused = true;
}