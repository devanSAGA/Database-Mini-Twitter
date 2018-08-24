----------------Queries for Twitter Database:

--Q1. Find the most popular user of each city.

Select Username,users.city from Users join (Select city,max(followers) as max from Users group by city) as x on (Users.city=x.city) where Users.followers=x.max;


--Q2. Find the most popular user of each country

Select DISTINCT Username,y.country from (Users natural join location) as y natural join (Select country,max(followers) as max from Users natural join location group by country)as x where y.followers=x.max;


--Q3. Fetch the number of users, from each city.

Select city,count(username) from users group by city;


--Q4. Fetch the list of users, the user is interested in.

SELECT Follower FROM Follow WHERE Following='goodpv';


--Q5. Fetch the list of users, who are interested in the user.

SELECT Following FROM Follow WHERE Follower='goodpv';


--Q6.  Show all the Users which are blocked by a particular user.

SELECT blocked_user FROM block WHERE username='goodpv';


--Q7. Fetch all tweets of a user in a chronological order.

SELECT tweetid,tweet_content, timestamp_t, city, likes, retweets FROM tweet WHERE username='goodpv' ORDER BY timestamp_t DESC;


--Q8. Fetch all the retweets done by a particular user.

SELECT tweet.username, tweet.tweet_content, tweet.timestamp_t, tweet.city, tweet.likes, tweet.retweets
FROM tweet JOIN retweets ON (tweet.tweetid=retweets.tweetid)
WHERE retweets.username='goodpv' ORDER BY retweets.timestamp_r DESC;


--Q9. Retrieve all the tweets of a particular user by most liked tweets.

SELECT tweetid,tweet_content, timestamp_t, city, likes, retweets FROM tweet WHERE username='goodpv' ORDER BY likes DESC;


--Q10. Retrieve all the tweets of a particular user by most retweeted tweets.

SELECT tweetid,tweet_content, timestamp_t, city, likes, retweets FROM tweet WHERE username='goodpv' ORDER BY retweets DESC;


--Q11. Fetch the number of tweets a person has tweeted from different locations.

SELECT city, count(tweetid) AS tweet_count, sum(likes) AS likes, sum(retweets) AS retweets FROM tweet
WHERE username='goodpv'
GROUP BY city
ORDER BY tweet_count DESC;


--Q12. Fetch all the tweets containing links.

Select username,tweet_content,timestamp_t from tweet where tweet_content like '%http://%' or tweet_content like '%https://%' or tweet_content like '%www.?%.?%'


--Q13. Search for specific keyword among the tweets during some span.

SELECT Tweet_Content,timestamp_t FROM tweet WHERE  Tweet_Content like '%keyword%' and timestamp_t between '2017-01-01' and '2017-11-11 ';


--Q14. Find the most popular tweet of each country.

Select username,tweet_content,(retweets*10 + likes) as engagement, y.country from (tweet natural join location) as y natural join (Select country,max((retweets*10 + likes)) as max from tweet natural join location group by country)as x where(x.max= ((y.retweets *10)+y.likes));


--Q15. Find top 10 tweets of all time.

Select username, tweet_content,(retweets*10 + likes) as engagement from tweet order by engagement desc limit 10;


--Q16. Most used hashtags of a particular user.

SELECT hashtag, count(*) AS freq FROM hashtag WHERE tweetid IN
(
    SELECT tweetid FROM tweet WHERE username='neekun'
) GROUP BY hashtag ORDER BY freq DESC;


--Q17.  Fetch all tweets related to a hashtag

SELECT tweet_content, username, timestamp_t, city, likes, retweets FROM tweet NATURAL JOIN hashtag WHERE hashtag='tea';


--Q18. Fetch most trending topic of a particular country from last week

SELECT hashtag, count(*) AS freq FROM hashtag WHERE tweetid IN
(
    SELECT tweetid FROM tweet NATURAL JOIN location WHERE country='India' and timestamp_t between current_date and current_date -interval '7 days'
) GROUP BY hashtag ORDER BY freq DESC;


--Q19. Display all the tweets of TOP 5 trending topics for a country

SELECT DISTINCT tweet_content, username, timestamp_t, city, likes, retweets FROM tweet NATURAL JOIN hashtag NATURAL JOIN location WHERE country='India' AND hashtag IN
(
    SELECT hashtag FROM hashtag WHERE tweetid IN
    (
        SELECT tweetid FROM tweet NATURAL JOIN location WHERE country='India'
    ) GROUP BY hashtag ORDER BY count(*) DESC LIMIT 5
}

--Q20. Fetch Percentage participation of each city between some time period

SELECT  * FROM citytweet('2016-10-10' , '2017-10-10');


--Q21. Fetch the Direct Messages between two users

SELECT senderid, receiverid, msg_content,timestamp_m FROM messages
WHERE (messages.senderid='goodpv' AND messages.receiverid='neekun') OR (messages.senderid='neekun' AND messages.receiverid='goodpv')
ORDER BY timestamp_m DESC;