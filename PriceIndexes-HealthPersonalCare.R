require(reshape2);

# Helper for splitting text into chunks
chunkify <- function (what, size=1)
    split(what, ceiling(seq_along(what) / size));

if (!file.exists('PriceIndexes-HealthPersonalCare.Intermediate.csv')) {
    files <- c('a', 'b', 'c', 'd', 'e', 'f');
    url <- function (which)
        paste0('http://www.statcan.gc.ca/cgi-bin/sum-som/fl/cstsaveascsv.cgi?filename=cpis13', which, '-eng.htm&lan=eng');
    dirtyFiles <- '';

    for (file in files) {
        filename <- paste0(file, '.csv');
        download.file(url(file), filename);
        # Read files as text first to clean them
        dirty <- readLines(filename);

        dirty <- paste(dirty, collapse='\n')
        dirtyFiles <- paste(dirtyFiles, dirty, sep='\n');
    }

    cat(dirtyFiles, file='PriceIndexes-HealthPersonalCare.Intermediate.csv');
}

# load the intermediate data - contains all data concatenated
intermediate <- readLines('PriceIndexes-HealthPersonalCare.Intermediate.csv');
# Filter out the garbage:
inds <- grep('(?:,{2,6} ?$)|(?:^$)', intermediate);
intermediate <- intermediate[-inds];
# Extract column names:
columns <- strsplit(intermediate[1], ',')[[1]];
columns <- c(columns[2:length(columns)], 'X.1');

inds <- grep('^,', intermediate);
intermediate <- intermediate[-inds];

# There are 8 observations per region, split into those 11 segments (National CPI is included)
data <- chunkify(intermediate, size=8);

# a.csv is Can/NL, b.csv is PEI/NS, c.csv is NB/QC, d.csv Ont/Man, e.csv is Sask/Alta, f.csv is BC
provs <- c('Can', 'NL', 'PEI', 'NS', 'NB', 'QC', 'Ont', 'Man', 'Sask', 'Alta', 'BC');

# Rename the indexes to reflect their region
names(data) <- provs;

all.data <- data.frame();
# Read the data back in and transpose
for (prov in provs) {
    # Unlist and collapse into a newline-delimited CSV string
    data.str <- paste(unlist(data[prov]), collapse='\n');

    # Convert to data.frame
    data.prov <- read.csv(textConnection(data.str), row.names=1, col.names=columns);

    # Remove blank column
    data.prov <- subset(data.prov, select=-c(X.1));
    data.prov <- t(data.prov);

    # Convert back from matrix to data.frame
    data.prov <- as.data.frame(data.prov, stringsAsFactors=F);
    data.prov$Region <- factor(prov, levels=provs);

    data.prov$Period <- as.factor(rownames(data.prov));
    rownames(data.prov) <- 1:nrow(data.prov);

    all.data <- rbind(all.data, data.prov);
}

# Rename time period
levels(all.data$Period) <- c('Nov2013', '%Δ(Nov2013-Nov2014)', 'Nov2014', 'Oct2014', '%Δ(Oct2014-Nov2014)');

# Melt (keeping region/period):
skinny <- melt(all.data, id=c('Region', 'Period'));

# Rename the variables
levels(skinny$variable) <- c('HealthPersonalCare', 'HealthCare', 'HealthCareGoods', 'HealthCareServices', 'PersonalCare', 'PersonalCareSuppEquip', 'PersonalCareServices');

# Output full dataset
write.table(skinny, file='PriceIndexes-HealthPersonalCareTidy.txt');
