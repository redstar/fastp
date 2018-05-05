// Written in the D programming language.
module dunittest;

extern (C++, class)
struct UnitTest
{
    void run();
    // TODO bool report(bool result, string message);
}
