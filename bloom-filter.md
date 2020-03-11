## File-based Bloom Filter for Java

A [Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter) is a probabilistic data structure designed to tell, rapidly and efficiently, 
whether an element is a member of a set. False positives are possible, but false negatives are not, which means query returns either 
_"possibly in set"_ or _"definitely not in set"_.

Most Bloom filter implementations for Java are based on data sets kept in memory which is a huge limitation 
when it comes to handle large data sets, in terms of performance and system stability. 

Our goal was to be able to efficiently handle Bloom filters with massive data sets, 
counted in billions of entries or multiple GBs of storage.

We tackled the problem of large data sets by creating a Bloom filter implementation that keeps the data in a file rather than in memory.

The algorithms are copied from _Google Guava_ but the used bit array is backed by a file instead of Java arrays. 
The data file is memory mapped (_mmapped_) to the process space, not loaded, so there is no need to explicitly read of write 
from/to the disk. Also the Java heap space is not involved in storing the data.

Our Bloom filter implementation is backed by two files:

- `filter_name.bloom` is metadata file containing filter parameters (e.g. false positive probability, number of insertions), 

- `filter_name.bloom-data` is data set file sized to fit the provided number of expected insertions.

It can efficiently handle sets that require multi-GB data storage, e.g. with billions of entries, and low false positive rates.
You can see concrete numbers in [the benchmark section](#performance-benchmark).

The implementation is wrapped with a reusable Java library called simply `bloom-filter`.

#### Installation and usage

The `bloom-filter` library is distributed through [Maven Central](https://search.maven.org/search?q=io.nixer).

```kotlin
dependencies {
    implementation("io.nixer:bloom-filter:0.1.0.0")
}
```

The filter to be used is available as implementation of `io.nixer.bloom.BloomFilter`.  

In order to obtain an instance use one of the factory methods defined at `io.nixer.bloom.FileBasedBloomFilter`:

- `create(..)` for building an empty filter from scratch,

- `open(..)` for access already existing filter from the backing files, which might contain multi-GB data sets.

For most cases you are probably going to go with the second option and open already existing filter. 

However the filter has to be created somehow anyway. 
In order to make this process more convenient we prepared [a handy CLI tool](#bloom-cli-tool).  

## Bloom CLI Tool

In addition to the Bloom filter library we provide a simple command line utility to manipulate the Bloom filter backing files, 
called `bloom-tool`.

#### Installation

`bloom-tool` is built using Gradle [application plugin](https://docs.gradle.org/current/userguide/application_plugin.html) 
so the package includes start scripts specific to various operating systems.

#### Download package from GitHub

The tool package is available on GitHub as an addition to 
[each release of Nixer Spring Plugin](https://github.com/nixer-io/nixer-spring-plugin/releases/latest).

#### Build from sources

Alternatively, it can be build from sources - to do so clone or download 
[Nixer Spring Plugin](https://github.com/nixer-io/nixer-spring-plugin) and build the project using Gradle:

```
./gradlew
```

The tool's package is going to appear under `bloom-tool/build/distributions` directory.

#### Usage

Unzip the `bloom-tool` package and invoke the following in order to see all commands and options:

```
bin/bloom-tool --help
```

#### Basic use case

Suppose we have a text file containing list of leaked credentials (e.g. one from [here](https://haveibeenpwned.com))
which we want to put into a Bloom filter. Each line in the file consist of a password hash (as hex strings) and additional info,
like prevalence, separated by colon `:`, e.g.
```
0000000A1D4B746FAA3FD526FF6D5BC8052FDB38:16
0000000CAEF405439D57847A8657218C618160B2:15
0000000FC1C08E6454BED24F463EA2129E254D43:40
```

Let's call this file `entries.txt` and assume it contains `500 million` entries, which means around `20 GB` of data.

In order to create a filter populated with all the hashes from this file use the following command:
```
bloom-tool build --name my.bloom --size 500000000 --separator : --field 0 --input-file entries.txt
```
Where `--field` says the hash should be taken the first value after splitting each line by the `:` separator. 
Remember fields are counted starting from `0`.

Note execution for this amount of data might take a while. For MacBook Pro Core i7 with 16GB RAM it was around 24 minutes.

#### Create a Bloom filter

Create a new filter `my.bloom` for 1M insertions and 1 to 1M false positive rate.
```
bloom-tool create --size=1000000 --fpp=1e-6 --name=my.bloom
```
Results in creating `my.bloom` metadata file and empty `my.bloom-data` data file.

#### Insert values into a Bloom filter

Insert lines from `entries.txt` into `my.bloom` filter, populating `my.bloom-data` file.
```
bloom-tool insert --name=my.bloom --input-file=entries.txt
```
or from input stream 
```
cat entries.txt | bloom-tool insert --name=my.bloom --stdin
```
alternatively
```
bloom-tool insert --name=my.bloom --stdin < entries.txt
```

Insert hexadecimal from `hashes.txt` to `my.bloom`. Useful if the filter is intended to be use from Java code generating some hashes.
```
bloom-tool insert --hex --name=my.bloom --input-file=hashes.txt
```

#### Check an element is present in a filter's dataset

Check if string `example` might be inserted in `my.bloom` filter, printing it to standard output if it might be true or skipping otherwise.
```
echo example | bloom-tool check --name=my.bloom --stdin
```

#### Performance benchmark

Execute performance benchmark and correctness verification of the Bloom filter implementation.
This might take a minute, or more for greater sizes.
```
bloom-tool benchmark --size 10000000 --fpp=1e-7
```

Sample result:

Performance numbers (date: 2018-08-24, on a MacBook 16GB RAM, the file generated had size 4GB ):
```
$ caffeinate bloom-tool benchmark --size=1000000000 --fpp=1e-7
Creating: /var/folders/f3/pqxz3z7s6g37nhv65114479r0000gn/T/bloom-benchmark-tmp3708262923291670873/test.bloom
Creation time       : PT1.063892385S
Parameters          : BloomFilterParameters{expectedInsertions=1000000000, falsePositivesProbability=1.0E-7, numHashFunctions=23, bitSize=33547704320, strategy=MURMUR128_MITZ_64, byteOrder=LITTLE_ENDIAN}
Inserting           : 1000000000 values
Insertion time      : PT41M42.06361178S
Insertion speed     : 399658.84 op/sec
Checking            : 2000000000 values (half exist, half should not exist)
Check time          : PT45M27.88090649S
Check speed         : 733163.21 op/sec
False Positives     : 123
False Positive rate : 0.00000012300000
FP rate evaluation  : good (122.92% target)
```
