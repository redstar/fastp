// Written in the D programming language.
import std.stdio;
import dcmdline;
import dunittest;

extern (C++) int cppmain();

enum FASTP_VER = "0.13.2";

int main(string[] args)
{
    // display version info if no argument is given
    if (args.length == 1) {
        writefln("fastp: an ultra-fast all-in-one FASTQ preprocessor\nversion %s", FASTP_VER);
    }
    if (args.length == 2 && args[1] == "test"){
        UnitTest tester;
        tester.run();
        return 0;
    }
    if (args.length == 2 && (args[1] == "-v" || args[1] == "--version")){
        writefln("fastp: an ultra-fast all-in-one FASTQ preprocessor\nversion %s", FASTP_VER);
        return 0;
    }

    Parser cmd;

    // input/output
    cmd.add!string("in1", 'i', "read1 input file name", true, "");
    cmd.add!string("out1", 'o', "read1 output file name", false, "");
    cmd.add!string("in2", 'I', "read2 input file name", false, "");
    cmd.add!string("out2", 'O', "read2 output file name", false, "");
    cmd.add("phred64", '6', "indicates the input is using phred64 scoring (it'll be converted to phred33, so the output will still be phred33)");
    cmd.add!int("compression", 'z', "compression level for gzip output (1 ~ 9). 1 is fastest, 9 is smallest, default is 2.", false, 2);

    // adapter
    cmd.add("disable_adapter_trimming", 'A', "adapter trimming is enabled by default. If this option is specified, adapter trimming is disabled");
    cmd.add!string("adapter_sequence", 'a', "the adapter for read1. For SE data, if not specified, the adapter will be auto-detected. For PE data, this is used if R1/R2 are found not overlapped.", false, "auto");
    cmd.add!string("adapter_sequence_r2", 0, "the adapter for read2 (PE data only). This is used if R1/R2 are found not overlapped. If not specified, it will be the same as <adapter_sequence>", false, "");

    // trimming
    cmd.add!int("trim_front1", 'f', "trimming how many bases in front for read1, default is 0", false, 0);
    cmd.add!int("trim_tail1", 't', "trimming how many bases in tail for read1, default is 0", false, 0);
    cmd.add!int("trim_front2", 'F', "trimming how many bases in front for read2. If it's not specified, it will follow read1's settings", false, 0);
    cmd.add!int("trim_tail2", 'T', "trimming how many bases in tail for read2. If it's not specified, it will follow read1's settings", false, 0);

    // polyG tail trimming
    cmd.add("trim_poly_g", 'g', "force polyG tail trimming, by default trimming is automatically enabled for Illumina NextSeq/NovaSeq data");
    cmd.add!int("poly_g_min_len", 0, "the minimum length to detect polyG in the read tail. 10 by default.", false, 10);
    cmd.add("disable_trim_poly_g", 'G', "disable polyG tail trimming, by default trimming is automatically enabled for Illumina NextSeq/NovaSeq data");
    
    // polyX tail trimming
    cmd.add("trim_poly_x", 'x', "enable polyX trimming in 3' ends.");
    cmd.add!int("poly_x_min_len", 0, "the minimum length to detect polyX in the read tail. 10 by default.", false, 10);

    // sliding window cutting for each reads
    cmd.add("cut_by_quality5", '5', "enable per read cutting by quality in front (5'), default is disabled (WARNING: this will interfere deduplication for both PE/SE data)");
    cmd.add("cut_by_quality3", '3', "enable per read cutting by quality in tail (3'), default is disabled (WARNING: this will interfere deduplication for SE data)");
    cmd.add!int("cut_window_size", 'W', "the size of the sliding window for sliding window trimming, default is 4", false, 4);
    cmd.add!int("cut_mean_quality", 'M', "the bases in the sliding window with mean quality below cutting_quality will be cut, default is Q20", false, 20);

    // quality filtering
    cmd.add("disable_quality_filtering", 'Q', "quality filtering is enabled by default. If this option is specified, quality filtering is disabled");
    cmd.add!int("qualified_quality_phred", 'q', "the quality value that a base is qualified. Default 15 means phred quality >=Q15 is qualified.", false, 15);
    cmd.add!int("unqualified_percent_limit", 'u', "how many percents of bases are allowed to be unqualified (0~100). Default 40 means 40%", false, 40);
    cmd.add!int("n_base_limit", 'n', "if one read's number of N base is >n_base_limit, then this read/pair is discarded. Default is 5", false, 5);

    // length filtering
    cmd.add("disable_length_filtering", 'L', "length filtering is enabled by default. If this option is specified, length filtering is disabled");
    cmd.add!int("length_required", 'l', "reads shorter than length_required will be discarded, default is 15.", false, 15);

    // low complexity filtering
    cmd.add("low_complexity_filter", 'y', "enable low complexity filter. The complexity is defined as the percentage of base that is different from its next base (base[i] != base[i+1]).");
    cmd.add!int("complexity_threshold", 'Y', "the threshold for low complexity filter (0~100). Default is 30, which means 30% complexity is required.", false, 30);
    
    // base correction in overlapped regions of paired end data
    cmd.add("correction", 'c', "enable base correction in overlapped regions (only for PE data), default is disabled");

    // umi
    cmd.add("umi", 'U', "enable unique molecular identifer (UMI) preprocessing");
    cmd.add!string("umi_loc", 0, "specify the location of UMI, can be (index1/index2/read1/read2/per_index/per_read, default is none", false, "");
    cmd.add!int("umi_len", 0, "if the UMI is in read1/read2, its length should be provided", false, 0);
    cmd.add!string("umi_prefix", 0, "if specified, an underline will be used to connect prefix and UMI (i.e. prefix=UMI, UMI=AATTCG, final=UMI_AATTCG). No prefix by default", false, "");
    cmd.add!int("umi_skip", 0, "if the UMI is in read1/read2, fastp can skip several bases following UMI, default is 0", false, 0);

    // overrepresented sequence analysis
    cmd.add("overrepresentation_analysis", 'p', "enable overrepresented sequence analysis.");
    cmd.add!int("overrepresentation_sampling", 'P', "one in (--overrepresentation_sampling) reads will be computed for overrepresentation analysis (1~10000), smaller is slower, default is 20.", false, 20);
    
    // reporting
    cmd.add!string("json", 'j', "the json format report file name", false, "fastp.json");
    cmd.add!string("html", 'h', "the html format report file name", false, "fastp.html");
    cmd.add!string("report_title", 'R', "should be quoted with \' or \", default is \"fastp report\"", false, "fastp report");

    // threading
    cmd.add!int("thread", 'w', "worker thread number, default is 3", false, 3);

    // split the output
    cmd.add!int("split", 's', "split output by limiting total split file number with this option (2~999), a sequential number prefix will be added to output name ( 0001.out.fq, 0002.out.fq...), disabled by default", false, 0);
    cmd.add!long("split_by_lines", 'S', "split output by limiting lines of each file with this option(>=1000), a sequential number prefix will be added to output name ( 0001.out.fq, 0002.out.fq...), disabled by default", false, 0);
    cmd.add!int("split_prefix_digits", 'd', "the digits for the sequential number padding (1~10), default is 4, so the filename will be padded as 0001.xxx, 0 to disable padding", false, 4);

    cmd.parse_check(args);

    return cppmain();
}
