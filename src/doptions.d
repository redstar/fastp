// Written in the D programming language.
module doptions;

import dutil : error_exit, check_file_valid;

enum
{
    UMI_LOC_NONE = 0,
    UMI_LOC_INDEX1 = 1,
    UMI_LOC_INDEX2 = 2,
    UMI_LOC_READ1 = 3,
    UMI_LOC_READ2 = 4,
    UMI_LOC_PER_INDEX = 5,
    UMI_LOC_PER_READ = 6,
}

struct LowComplexityFilterOptions
{
    bool enabled = false;
    double threshold = 0.3;
}

struct OverrepresentedSequenceAnasysOptions
{
    bool enabled = false;
    int sampling = 20;
}

struct PolyGTrimmerOptions
{
    bool enabled = false;
    int minLen = 10;
}

struct PolyXTrimmerOptions
{
    bool enabled = false;
    int minLen = 10;
}

struct UMIOptions
{
    bool enabled = false;
    int location = UMI_LOC_NONE;
    int length = 0;
    int skip = 0;
    string prefix;
    string separator;
}

struct CorrectionOptions
{
    bool enabled = false;
}

struct QualityCutOptions
{
    // enable 5' cutting by quality
    bool enabled5 = false;
    // enable 3' cutting by quality
    bool enabled3 = false;
    // the sliding window size for cutting by quality
    int windowSize = 4;
    // the mean quality requirement for cutting by quality
    int quality = 20;
}

struct SplitOptions
{
    bool enabled = false;
    // number of files
    int number = 0;
    // lines of each file
    long size = 0;
    // digits number of file name prefix, for example 0001 means 4 digits
    int digits = 4;
    // need evaluation?
    bool needEvaluation = false;
    bool byFileNumber = false;
    bool byFileLines = false;
}

struct AdapterOptions
{
    bool enabled = true;
    string sequence;
    string sequenceR2;
    bool hasSeqR1 = false;
    bool hasSeqR2 = false;
}

struct TrimmingOptions
{
    // trimming first cycles for read1
    int front1 = 0;
    // trimming last cycles for read1
    int tail1 = 0;
    // trimming first cycles for read2
    int front2 = 0;
    // trimming last cycles for read2
    int tail2 = 0;
}

struct QualityFilteringOptions
{
    // quality filter enabled
    bool enabled = true;
    // if a base's quality phred score < qualifiedPhred, then it's considered as a low_qual_base
    char qualifiedQual = '0'; // '0' = Q15
    // if low_qual_base_num > lowQualLimit, then discard this read
    int unqualifiedPercentLimit = 40;
    // if n_base_number > nBaseLimit, then discard this read
    int nBaseLimit = 5;
}

struct ReadLengthFilteringOptions
{
    // length filter enabled
    bool enabled = false;
    // if read_length < requiredLength, then this read is discard
    int requiredLength = 15;
}

struct Options
{
    void init()
    {
    }

    bool isPaired()
    {
        return in2.length > 0;
    }

    bool validate()
    {
        if (in1.length == 0)
        {
            error_exit("read1 input should be specified by --in1");
        } else {
            check_file_valid(in1);
        }

        if (in2.length == 0 && out2.length > 0)
        {
            error_exit("read2 output is specified (--out2), but read2 input is not specified (--in2)");
        }

        if (in2.length > 0) {
            check_file_valid(in2);

            if (out1.length > 0 && out2.length == 0)
            {
                error_exit("paired-end input, read1 output should be specified together with read2 output (--out2 needed) ");
            }
            if (out1.length == 0 && out2.length > 0)
            {
                error_exit("paired-end input, read1 output should be specified (--out1 needed) together with read2 output ");
            }
        }

        if (out1.length > 0)
        {
            //check_file_writable(out1);
            if (out1 == out2) {
                error_exit("read1 output (--out1) and read1 output (--out2) should be different");
            }
        }
        if (out2.length > 0)
        {
            //check_file_writable(out2);
        }

        if (compression < 1 || compression > 9)
            error_exit("compression level (--compression) should be between 1 ~ 9, 1 for fastest, 9 for smallest");

        if (thread < 1 || thread > 16)
            error_exit("thread number (--thread) should be 1 ~ 16, suggest 1 ~ 8");

        if (trim.front1 < 0 || trim.front1 > 30)
            error_exit("trim_front1 (--trim_front1) should be 0 ~ 30, suggest 0 ~ 4");

        if (trim.tail1 < 0 || trim.tail1 > 30)
            error_exit("trim_tail1 (--trim_tail1) should be 0 ~ 30, suggest 0 ~ 4");

        if (trim.front2 < 0 || trim.front2 > 30)
            error_exit("trim_front2 (--trim_front2) should be 0 ~ 30, suggest 0 ~ 4");

        if (trim.tail2 < 0 || trim.tail2 > 30)
            error_exit("trim_tail2 (--trim_tail2) should be 0 ~ 30, suggest 0 ~ 4");

        if (qualfilter.qualifiedQual - 33 < 0 || qualfilter.qualifiedQual - 33 > 50)
            error_exit("qualitified phred (--qualified_quality_phred) should be 0 ~ 50, suggest 10 ~ 20");

        if (qualfilter.unqualifiedPercentLimit < 0 || qualfilter.unqualifiedPercentLimit > 100)
            error_exit("unqualified percent limit (--unqualified_percent_limit) should be 0 ~ 100, suggest 20 ~ 60");

        if (qualfilter.nBaseLimit < 0 || qualfilter.nBaseLimit > 50)
            error_exit("N base limit (--n_base_limit) should be 0 ~ 50, suggest 3 ~ 10");

        if (lengthFilter.requiredLength < 0)
            error_exit("length requirement (--length_required) should be >0, suggest 15 ~ 100");

        if (split.enabled)
        {
            if (split.digits < 0 || split.digits > 10)
                error_exit("you have enabled splitting output to multiple files, the digits number of file name prefix (--split_prefix_digits) should be 0 ~ 10.");

            if (split.byFileNumber)
            {
                if (split.number < 2 || split.number >= 1000)
                    error_exit("you have enabled splitting output by file number, the number of files (--split) should be 2 ~ 999.");
            }

            if (split.byFileLines)
            {
                if (split.size < 1000/4)
                    error_exit("you have enabled splitting output by file lines, the file lines (--split_by_lines) should be >= 1000.");
            }
        }

        if (qualityCut.enabled5 || qualityCut.enabled3)
        {
            if (qualityCut.windowSize < 2 || qualityCut.windowSize > 10)
                error_exit("the sliding window size for cutting by quality (--cut_window_size) should be between 2~10.");
            if (qualityCut.quality < 1 || qualityCut.quality > 30)
                error_exit("the mean quality requirement for cutting by quality (--cut_mean_quality) should be 1 ~ 30, suggest 15 ~ 20.");
        }

        if (adapter.sequence != "auto" && adapter.sequence.length > 0)
        {
            // validate adapter sequence for single end adapter trimming
            if (adapter.sequence.length < 4 || adapter.sequence.length > 100)
                error_exit("the sequence of <adapter_sequence> should be 4 ~ 100 long");

            // validate bases
            for (int i=0; i < adapter.sequence.length; i++)
            {
                char c = adapter.sequence[i];
                if (c!='A' && c!='T' && c!='C' && c!='G')
                {
                    error_exit("the adapter <adapter_sequence> can only have bases in {A, T, C, G}, but the given sequence is: " ~ adapter.sequence);
                }
            }

            adapter.hasSeqR1 = true;
        }

        if (adapter.sequenceR2 != "auto" && adapter.sequenceR2.length > 0)
        {
            // validate adapter sequenceR2 for single end adapter trimming
            if (adapter.sequenceR2.length < 4 || adapter.sequenceR2.length > 100)
                error_exit("the sequence of <adapter_sequence_r2> should be 4 ~ 100 long");

            // validate bases
            for (int i=0; i < adapter.sequenceR2.length; i++)
            {
                char c = adapter.sequenceR2[i];
                if (c!='A' && c!='T' && c!='C' && c!='G')
                {
                    error_exit("the adapter <adapter_sequence_r2> can only have bases in {A, T, C, G}, but the given sequenceR2 is: " ~ adapter.sequenceR2);
                }
            }

            adapter.hasSeqR2 = true;
        }

        if (correction.enabled && !isPaired())
        {
            import std.stdio : writeln, stderr;
            stderr.writeln("WARNING: base correction is only appliable for paired end data, ignored -c/--correction");
            correction.enabled = false;
        }

        if (umi.enabled)
        {
            if (umi.location == UMI_LOC_READ1 || umi.location == UMI_LOC_READ2 || umi.location == UMI_LOC_PER_READ)
            {
                if (umi.length<1 || umi.length>100)
                    error_exit("UMI length should be 1~100");
                if (umi.skip<0 || umi.skip>100)
                    error_exit("The base number to skip after UMI <umi_skip> should be 0~100");
            }
            else
            {
                if (umi.skip>0)
                    error_exit("Only if the UMI location is in read1/read2/per_read, you can skip bases after UMI");
                if (umi.length>0)
                    error_exit("Only if the UMI location is in read1/read2/per_read, you can set the UMI length");
            }
            if (umi.prefix.length > 0)
            {
                if (umi.prefix.length >= 10)
                    error_exit("UMI prefix should be shorter than 10");
                for (int i=0; i < umi.prefix.length; i++)
                {
                    char c = umi.prefix[i];
                    if (!(c>='A' && c<='Z') && !(c>='a' && c<='z') && !(c>='0' && c<='9'))
                    {
                        error_exit("UMI prefix can only have characters and numbers, but the given is: " ~ umi.prefix);
                    }
                }
            }
            if (umi.separator.length > 0)
            {
                if (umi.separator.length > 10)
                    error_exit("UMI separator cannot be longer than 10 base pairs");
                // validate bases
                for (int i=0; i < umi.separator.length; i++)
                {
                    char c = umi.separator[i];
                    if (c!='A' && c!='T' && c!='C' && c!='G')
                    {
                        error_exit("UMI separator can only have bases in {A, T, C, G}, but the given sequence is: " ~ umi.separator);
                    }
                }
            }
        }

        if (overRepAnalysis.sampling < 1 || overRepAnalysis.sampling > 10000)
            error_exit("overrepresentation_sampling should be 1~10000");

        return true;
    }

    bool adapterCuttingEnabled()
    {
        if (adapter.enabled)
        {
            if (isPaired() || adapter.sequence.length > 0)
                return true;
        }
        return false;
    }

    // file name of read1 input
    string in1 = "";
    // file name of read2 input
    string in2 = "";
    // file name of read1 output
    string out1 = "";
    // file name of read1 output
    string out2 = "";
    // json file
    string jsonFile;
    // html file
    string htmlFile;
    // html report title
    string reportTitle = "fastp report";
    // compression level
    int compression = 2;
    // the input file is using phred64 quality scoring
    bool phred64 = false;
    // worker thread number
    int thread = 1;
    // trimming options
    TrimmingOptions trim;
    // quality filtering options
    QualityFilteringOptions qualfilter;
    // length filtering options
    ReadLengthFilteringOptions lengthFilter;
    // adapter options
    AdapterOptions adapter;
    // multiple file splitting options
    SplitOptions split;
    // options for quality cutting
    QualityCutOptions qualityCut;
    // options for base correction
    CorrectionOptions correction;
    // options for UMI
    UMIOptions umi;
    // 3' end polyG trimming, default for Illumina NextSeq/NovaSeq
    PolyGTrimmerOptions polyGTrim;
    // 3' end polyX trimming
    PolyXTrimmerOptions polyXTrim;
    // for overrepresentation analysis
    OverrepresentedSequenceAnasysOptions overRepAnalysis;
    long[string] overRepSeqs1;
    long[string] overRepSeqs2;
    int seqLen1;
    int seqLen2;
    // low complexity filtering
    LowComplexityFilterOptions complexityFilter;
}
