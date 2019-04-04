setwd("/Volumes/GoogleDrive/My\ Drive/ecodatalab/census")

data_to_convert_path <- 'data/ZCTA/2011_5YR_ZCTA-Old.csv'
output_path <- '~/Desktop/School\ Stuff/Census-Team/playground'
zcta_geo_id <- 'Geo_ZCTA5' # The geotag of the ZCTA (i.e. Geo_ZCTA5), should be the same as ZCTA5 (3 digits)
col_to_convert <- 'SE_T002_002' # The name of the column you want to convert to county level data
# Readable name of column you're converting (i.e. Instead of SE_T002_002, name it pop_density), optionally just put the same as col_to_convert
col_name <- 'ZCTA_DENSITY'


zcta_data_vec <- c(zcta_geo_id, col_to_convert)

# Read in relationship data, then grab just the zcta, geoid, and county percentage
# Need zcta just cuz, geoid because that's the id that relates all common zcta's, and county percentage for weights
relation <- read.table(file='data/RELATIONSHIPS/zcta_county_rel_10.txt', header=TRUE, sep=',')
relation <- relation[,c('ZCTA5', 'GEOID', 'COPOPPCT')]

# Read in file to convert, then take the 2 columns we need
zcta_data <- read.csv(data_to_convert_path)
zcta_data <- zcta_data[,zcta_data_vec]
names(zcta_data) <- c('ZCTA5', col_name)

# Create a table preds (not yet the predictions) by merging the relationship table with the given table based on the ZCTA
preds <- merge(relation, zcta_data, by='ZCTA5')

# Weights are the county percentages within each zcta, multiply those by the column to convert's values
preds$weights <- preds[,'COPOPPCT'] * preds[,col_name] / 100
# Sum all the weighted values through grouping/aggregating
preds <- aggregate(preds[,'weights'], by=list(preds[,'GEOID']), FUN=sum)
names(preds) <- c('GEOID', paste(col_name, "county_level", sep="_"))

write.csv(preds, file = paste(output_path, "test.csv", sep="/"))