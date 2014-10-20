library(quadprog)
source("read_yahoo.R")

# calculates the adjusted close for the specified period
Adj.close <- function(data, period){
	data$Adj.Close[period];
}

# calculates the 'B' vector, which is required as an intermediary step
# when solving for an efficient portfolio
create.B.vector <- function(number.of.symbols, mu){
	b.vector <- c(rep(0, number.of.symbols), mu, 1)
}

# calculates the 'A' matrix, which is required as an intermediary step;
# requires the sigma matrix
get.A.matrix.with.sigma <- function(tickers, data, start, lookback, sigma.matrix){
	mu.vector <- get.mu.vector(tickers, data, start, lookback);
	n <- nrow(sigma.matrix) + 2;
	top.matrix <- cbind(2*sigma.matrix, mu.vector, rep(1,n-2));
	mid.vector <- c(mu.vector, 0, 0);
	bot.vector <- c(rep(1,n-2), 0, 0);
	A.matrix <- rbind(top.matrix, mid.vector, bot.vector);
}

# calculates the efficient portfolio; requires the sigma matrix
get.efficient.portfolio.with.sigma <- function(tickers, data, start, lookback, mu, sigma.matrix){
	A.matrix <- get.A.matrix.with.sigma(tickers, data, start, lookback, sigma.matrix);
	b.vector <- create.B.vector(length(tickers), mu);
	z.matrix <- solve(A.matrix)%*%b.vector;
	x.vector <- z.matrix[1:length(tickers)];
}

# calculates the 'mu' vector
get.mu.vector <- function(tickers, data, start, lookback){
	n <- length(tickers);
	mu.vector <- vector();
	for(i in 1:n){
		data.subset <- trimmed.subset(tickers[i], data, start, lookback);
		mu <- mean.return(data.subset);
		mu.vector <- c(mu.vector,mu);
	}
	mu.vector;
}

# finds the return for a specific period
get.return <- function(tickers, weights, data, period){
	returns.vector <- vector();
	for(i in 1:length(weights)){
		data.subset <- get.subset(tickers[i], data);
		ticker.return <- (Adj.close(data.subset, period) - Adj.close(data.subset, period + 1)) / Adj.close(data.subset, period + 1);
		returns.vector <- c(returns.vector, ticker.return);
	}
	period.return <- 0;
	for(i in 1:length(weights)){
		period.return <- period.return + weights[i]*returns.vector[i];
	}
	period.return;
}

# calculates the returns for 'data', which must include a single symbol
get.returns <- function(data) {
	returns.vec <- rep(0,nrow(data))
	for (i in 1:(nrow(data)-1)) {
		returns.vec[i] <- (data$Adj.Close[i] - data$Adj.Close[i + 1])/data$Adj.Close[i + 1]
	}
	returns.vec
}

# calculates the 'sigma' matrix
get.sigma.matrix <- function(names, data, start, lookback){
	#find the matrix size
	n <- length(names);
	end <- start + lookback - 1;
	#initialize the sigma matrix
	sigma.mat <- matrix(data=rep(0,n^2), nrow=n, ncol=n);
	#ensure rets doesn't exists
	if(exists('rets')){
		rm(rets);
	}
	#find returns for all the symbols
	for(i in 1:n){
		ret <- get.returns(get.subset(names[i], data));
		if(exists("rets")){
			rets <- rbind(rets, ret);
		} else {
			rets <- ret;
		}
	}
	#find average returns for all symbols
	mu.rets <- vector();
	for(i in 1:n){
		mu.rets <- c(mu.rets,mean(rets[i,start:end]));
	}
	#iterate over rows and columns
	for(i in 1:n){
		for(j in 1:n){
			#if i == j find the variance
			if(i == j){
				var <- sum(rets[i,start:end]*rets[i,start:end]) / (lookback - 1) - (mu.rets[i]^2)*lookback/(lookback-1);
				sigma.mat[i,j] <- var;
			}
			#when i < j calculate covariances, otherwise, copy from the top half of the matrix
			else if (i < j) {
				covar <- (sum(rets[i,start:end]*rets[j,start:end]) - 2*mu.rets[i]*mu.rets[j]*lookback) / lookback + mu.rets[i]*mu.rets[j];
				sigma.mat[i,j] <- covar
			}
			else {
				sigma.mat[i,j] <- sigma.mat[j,i]
			}
		}
	}
	sigma.mat
}

# gets 'symbol' from 'data'
get.subset <- function(symbol, data) {
	symbol.data <- data[data$symbol==symbol,]
}

# calculates the mean return for provided data
mean.return <- function(data) {
	returns.vec <- get.returns(data)
	mean(returns.vec[1:(length(returns.vec)-1)])
}

# iterates through the data, finding the portfolio return for each period
simulate <- function(tickers, data, start, lookback, mu, short_sales = 1){
	initial.investment <- 1.0;
	portfolio.value <- initial.investment;
	i <- start;
	returns <- vector();
	while(i > 1){
		sigma.matrix <- get.sigma.matrix(tickers, data, i, lookback);
		if (short_sales == 1) {
			portfolio.weights <- get.efficient.portfolio.with.sigma(tickers, data, i, lookback, mu, sigma.matrix);
		}
		else {
			portfolio.weights <- get.efficient.portfolio.no.short.sales(tickers, data, i, lookback, mu, sigma.matrix);
		}
		period.return <- get.return(tickers, portfolio.weights, data, i - 1);
		portfolio.value <- portfolio.value*(1+ period.return);
		returns <- c(returns, period.return);
		i <- i - 1;
	}
	returns;
}

# trims a subset of length 'lenght' starting at 'start' of symbol 'symbol' from 'data'
trimmed.subset <- function(symbol, data, start, length) {
	symbol.data <- get.subset(symbol, data);
	symbol.data[start:(start+length-1),]
}