# include required files
source("base_functions.R")

# get the list of symbols
tickers <- dow.tickers

# only get data from server if it hasn't been fetched yet
if (exists("ticker.data") != TRUE){
	ticker.data <- get.dow30(from=Sys.Date()-365*30, to=Sys.Date()-365*10, interval='m')
}

# get user data for lookback period in months and desired monthly rate of return
lookback <-as.numeric(readline("Enter a lookback period in months: "))
desired.mu <- as.numeric(readline("Enter a desired expected return (mu): "))

# simulate
print("Begin simulation...")
sim.returns <- simulate(tickers, ticker.data, lookback, lookback, desired.mu, short_sales = 0)
print("...Done!")
print("Test Parameters:")
print(sprintf("Lookback period: %f", lookback))
print(sprintf("Desired expected return: %f", desired.mu))
print("Results:")
calculated.mu <- mean(sim.returns)
print(sprintf("Resulting expected return: %f", calculated.mu))
standard.deviation <- sd(sim.returns)
print(sprintf("Standard deviation: %f", standard.deviation))
sharpe.ratio <- calculated.mu / standard.deviation
print(sprintf("Sharpe Ratio: %f", sharpe.ratio))