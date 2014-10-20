get.quotes <- function( ticker,
												from=(Sys.Date()-365),
												to=(Sys.Date()),
												interval="d") {
	# define parts of the URL
	base <- "http://ichart.finance.yahoo.com/table.csv?";
	symbol <- paste("s=", ticker, sep="");

	#months are numbered from 00 to 11, so format the month correctly
	from.month <- paste("&a=",
		formatC(as.integer(format(from, "%m"))-1, width=2, flag="0"),
		sep="");
	from.day <- paste("&b=", format(from, "%d"), sep="");
	from.year <- paste("&c=", format(from, "%Y"),sep="");
	to.month <- paste("&d=",
		formatC(as.integer(format(to,"%m"))-1, width=2, flag="0"),
		sep="");
	to.day <- paste("&e=", format(to,"%d"), sep="");
	to.year <- paste("&f=", format(to,"%Y"), sep="");
	inter <- paste("&g=", interval, sep="");
	last <- "&ignore=.csv";

	#put together the url
	url <- paste(base, symbol, from.month, from.day, from.year, to.month, to.day, to.year, inter, last, sep="");

	#get the file
	print("Reading...")
	print(symbol)
	tmp <- read.csv(url);

	#add a new column with ticker symbol labels
	cbind(symbol=ticker,tmp);
}

get.multiple.quotes <- function(tickers,
																from=(Sys.Date()-365),
																to=(Sys.Date()),
																interval="d") {
	tmp <- NULL;
	for (ticker in tickers) {
		if(is.null(tmp))
			tmp <- get.quotes(ticker, from, to, interval)
		else tmp <- rbind(tmp, get.quotes(ticker, from, to, interval))
	}
	tmp
}

dow.tickers <- c("MMM", "AA", "AXP", "T", "BAC", "BA", "CAT", "CVX", "CSCO", "KO", "DD", "XOM", "GE", "HPQ", "HD", "INTC", "IBM", "JNJ", "JPM", "MCD", "MRK", "MSFT", "PFE", "PG", "TRV", "UTX", "VZ", "WMT", "DIS")

get.dow30 <- function(from=(Sys.Date()-365), to=(Sys.Date()), interval="d") {
	dow30 <- get.multiple.quotes(dow.tickers, from, to, interval)
	dow30$Date <- as.Date(dow30$Date)
	dow30
}

#returns the values for the DJIA index
get.dow30.index <- function(from=(Sys.Date()-365), to=(Sys.Date()), interval="d") {
	djia.index <- get.quotes(ticker="DIA",from, to, interval)
	djia.index$Date <- as.Date(djia.index$Date)
	djia.index
}