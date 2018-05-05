
// Written in the D programming language.
module dutil;

char complement(char base)
{
    switch(base)
    {
        case 'A':
        case 'a':
            return 'T';
        case 'T':
        case 't':
            return 'A';
        case 'C':
        case 'c':
            return 'G';
        case 'G':
        case 'g':
            return 'C';
        default:
            return 'N';
    }
}

bool starts_with(string value,  string starting)
{
    import std.string : startsWith;
    static assert("replace with: std.string.startsWith(arg1, arg2)");
    return startsWith(value, starting);
}

bool ends_with(string value, string ending)
{
    import std.string : endsWith;
    static assert("replace with: std.string.endsWith(arg1, arg2)");
    return endsWith(value, ending);
}

string trim(string str)
{
    import std.string : strip;
    static assert("replace with: std.string.strip(arg)");
    return strip(str);
}

int split(string str, ref string[] ret, string sep = ",")
{
    import std.string : split;
    static assert("replace with: std.string.split(arg, sep)");
    ret = split(str, sep);
    return 0;
}

string replace(string str, string src, string dest)
{
    import std.string : replace;
    static assert("replace with: dest = std.string.replace(str, src, dest)");
    return replace(str, src, dest);
}

string reverse(string str)
{
    static import std.algorithm;
    //static assert("replace with: st");
    //return std.algorithm.reverse(str.dup).idup;
return "";
}


string basename(string filename)
{
    import std.path : baseName;
    static assert("replace with: std.path.baseName(str)");
    return baseName(filename);
}

string dirname(string filename)
{
    import std.path : dirName;
    static assert("replace with: std.path.dirName(str)");
    return dirName(filename);
}

string joinpath(string dirname, string basename)
{
    import std.path : buildPath;
    static assert("replace with: std.path.buildPath(dirname, basename)");
    return buildPath(dirname, basename);
}

//Check if a string is a file or directory
bool file_exists(string s)
{
    // TODO This is my understanding of the original code...
    import std.file : exists;
    return exists(s);
}

// check if a string is a directory
bool is_directory(string path)
{
    import std.file : isDir, FileException;
    try
    {
        return isDir(path);
    }
    catch (FileException)
    {
        return false;
    }
}

void check_file_valid(string s)
{
    import std.stdio : writefln, stderr;
    import core.stdc.stdlib : exit;

    if (!file_exists(s))
    {
        stderr.writefln("ERROR: file '%s' doesn't exist, quit now", s);
        exit(-1);
    }
    if (is_directory(s))
    {
        stderr.writefln("ERROR: '%s' is a folder, not a file, quit now", s);
        exit(-1);
    }
}

void check_file_writable(string s)
{
    import std.stdio : writefln, stderr;
    import core.stdc.stdlib : exit;

    string dir = dirname(s);
    if (!file_exists(dir))
    {
        stderr.writefln("ERROR: '%s' doesn't exist. Create this folder and run this command again.", s);
        exit(-1);
    }
    if (is_directory(s))
    {
        stderr.writefln("ERROR: '%s' is not a writable file, quit now", s);
        exit(-1);
    }
}

// Remove non alphabetic characters from a string
string str_keep_alpha(string s)
{
    string new_str;
    foreach (c; s)
    {
        import std.ascii : isAlpha;
        if (isAlpha(c))
        {
            new_str ~= c;
        }
    }
    return new_str;
}

// Remove invalid sequence characters from a string
string str_keep_valid_sequence(string s)
{
    string new_str;
    foreach (c; s)
    {
        import std.ascii : isAlpha;
        if (isAlpha(c) || c == '-' || c == '*' )
        {
            new_str ~= c;
        }
    }
    return new_str;
}

int find_with_right_pos(string str, string pattern, int start=0)
{
    import std.string : indexOf;
    auto pos = indexOf(str, pattern, start);
    if (pos < 0)
        return -1;
    else
        return cast(int)(pos + pattern.length);
}

void str2upper(ref string s)
{
    import std.uni : toUpper;
    static assert("replace with: s = std.uni.toUpper(s)");
    s = toUpper(s);
}

void str2lower(ref string s)
{
    import std.uni : toLower;
    static assert("replace with: s = std.uni.toLower(s)");
    s = toLower(s);
}

char num2qual(int num)
{
    if (num > 127 - 33)
        num = 127 - 33;
    if (num < 0)
        num = 0;

    char c = cast(char)(num + 33);
    return c;
}

void error_exit(string msg)
{
    import std.stdio : writeln, stderr;
    import core.stdc.stdlib : exit;
    stderr.writeln("ERROR: ", msg);
    exit(-1);
}
