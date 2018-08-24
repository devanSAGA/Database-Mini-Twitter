--DROP SCHEMA Twitter CASCADE;

CREATE SCHEMA twitter;
SET SEARCH_PATH TO twitter;

CREATE TABLE location (
city        VARCHAR(50),
country        VARCHAR(50) NOT NULL,

PRIMARY KEY (city)
);


CREATE TABLE users (
username    VARCHAR(40),
firstName    VARCHAR(50) NOT NULL,
lastName    VARCHAR(50),
gender        CHAR(1) NOT NULL CHECK ( Gender in ('M', 'F')) ,
birthDate    DATE NOT NULL,
bio        Varchar(180),
city         Varchar(50),
followers   INT  NOT NULL DEFAULT 0,
following   INT  NOT NULL DEFAULT 0,

PRIMARY KEY (username),
FOREIGN KEY (city) REFERENCES location(city)
ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE authentication (
email    VARCHAR(100),
username    VARCHAR(40) UNIQUE,
password    VARCHAR(32) NOT NULL,
sec_que     VARCHAR(200) NOT NULL,
sec_ans     VARCHAR(80) NOT NULL,

PRIMARY KEY (email),
FOREIGN KEY (username) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE follow (
follower    VARCHAR(40),
following    VARCHAR(40),

PRIMARY KEY (follower, following),
FOREIGN KEY (follower) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY (following) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE block(
username        VARCHAR(40),
blocked_user     VARCHAR(40),

PRIMARY KEY (username, blocked_user ),
FOREIGN KEY (username) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY (blocked_user) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE tweet(
tweetid          INT,
tweet_content     VARCHAR(280) NOT NULL,
username         VARCHAR(40) NOT NULL,
timestamp_t     TIMESTAMP NOT NULL,
city             VARCHAR(50),
likes           INT NOT NULL DEFAULT 0,
retweets        INT NOT NULL DEFAULT 0,
 
PRIMARY KEY (tweetid),
FOREIGN KEY (city) REFERENCES location(city)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY     (username) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE hashtag
(
  hashtag varchar(279),
  tweetid INT,
  PRIMARY KEY (hashtag, tweetid),
  FOREIGN KEY (tweetid) REFERENCES tweet(tweetid)
    ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE retweets (
tweetid            INT,
username            VARCHAR(40),
timestamp_r        TIMESTAMP NOT NULL,

PRIMARY KEY     (tweetid, username),
FOREIGN KEY     (tweetid) REFERENCES tweet(tweetid)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY     (username) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE likes (
tweetid           INT,
username        VARCHAR(40),
timeStamp_l   TIMESTAMP NOT NULL,

PRIMARY KEY     (tweetid, username),
FOREIGN KEY     (tweetid) REFERENCES tweet(tweetid)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY     (username) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE messages (
messageid        VARCHAR(40),
senderid        VARCHAR(40) NOT NULL,
receiverid       VARCHAR(40) NOT NULL,
msg_content        VARCHAR(1000) NOT NULL,
timestamp_m    TIMESTAMP NOT NULL,

PRIMARY KEY    (messageid),
FOREIGN KEY     (senderid) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY     (receiverid) REFERENCES users(username)
ON DELETE CASCADE ON UPDATE CASCADE
);
