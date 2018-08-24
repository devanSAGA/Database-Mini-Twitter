--Stored Procedures:

-----------------------------------------------------------------------------------------------------------------
-- Percentage participation of users from each city between some time period
CREATE TABLE cityper
(
  city character varying(50),
  percent real
);

CREATE OR REPLACE FUNCTION twitter.citytweet(d1 date, d2 date)
  RETURNS SETOF twitter.cityper AS
$BODY$
DECLARE
    total real;
    c cityper;
    r cityper%rowtype;
BEGIN
    SELECT count(tweetid) into total FROM tweet where timestamp_t between d1 and d2;
    FOR r in SELECT city,count(tweetid) as percent FROM tweet where timestamp_t between d1 and d2 group by city LOOP
        c.city=r.city;
        c.percent=r.percent*100/total;
        RETURN NEXT c;
    END LOOP;
    RETURN;
END $BODY$
  LANGUAGE plpgsql
-----------------------------------------------------------------------------------------------------------------------

--Triggers:
------------------------------------------------------------------------------------------------------------------
--Changes the follower count in user table whenever a user follows or unfollows
CREATE FUNCTION update_follower_count() RETURNS TRIGGER AS $users$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE users SET following = users.following + 1 WHERE users.username = NEW.follower;
        UPDATE users SET followers = users.followers + 1 WHERE users.username = NEW.following;
        RETURN NEW;
    ELSEIF (TG_OP = 'DELETE') THEN
        UPDATE users SET following = users.following - 1 WHERE users.username = OLD.follower;
        UPDATE users SET followers = users.followers - 1 WHERE users.username = OLD.following;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$users$ LANGUAGE plpgsql;


CREATE TRIGGER users
AFTER INSERT OR DELETE ON follow
    FOR EACH ROW EXECUTE PROCEDURE update_follower_count();

-----------------------------------------------------------------------------------------------------------
--Changes the retweet count in tweet table whenever a tweet is retweeted/revert from retweet
CREATE FUNCTION update_retweet_count() RETURNS TRIGGER AS $tweet$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE tweet SET retweets = tweet.retweets + 1 WHERE tweetid = NEW.tweetid;
        RETURN NEW;
    ELSEIF (TG_OP = 'DELETE') THEN
        UPDATE tweet SET retweets = tweet.retweets - 1 WHERE tweetid = NEW.tweetid;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$tweet$ LANGUAGE plpgsql;

CREATE TRIGGER retweets_counter
AFTER INSERT OR DELETE ON retweets
    FOR EACH ROW EXECUTE PROCEDURE update_retweet_count();
------------------------------------------------------------------------------------------------------
--Changes the like count in tweet table whenever a tweet liked/revert from like
CREATE FUNCTION update_likes_count() RETURNS TRIGGER AS $tweet$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE tweet SET  likes = tweet.likes + 1 WHERE tweetid = NEW.tweetid;
        RETURN NEW;
    ELSEIF (TG_OP = 'DELETE') THEN
        UPDATE tweet SET  likes = tweet.likes - 1 WHERE tweetid = NEW.tweetid;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$tweet$ LANGUAGE plpgsql;

CREATE TRIGGER like_counter
AFTER INSERT OR DELETE ON likes
    FOR EACH ROW EXECUTE PROCEDURE update_likes_count();

------------------------------------------------------------------
--Decreases the like and retweet count from the tweets in which the blocked user has contributed to those
CREATE OR REPLACE FUNCTION update_blocked() RETURNS TRIGGER AS $users$
BEGIN
    
    IF (TG_OP = 'INSERT') THEN
       DELETE FROM follow WHERE (follower = NEW.username AND following = NEW.blocked_user) OR (following = NEW.username AND follower = NEW.blocked_user);

       DELETE FROM likes WHERE (username = NEW.username AND tweetid IN (SELECT tweetid FROM tweet WHERE username=NEW.blocked_user));
       DELETE FROM likes WHERE (username = NEW.blocked_user AND tweetid IN (SELECT tweetid FROM tweet WHERE username=NEW.username));
       
       DELETE FROM retweets WHERE (username = NEW.username AND tweetid IN (SELECT tweetid FROM tweet WHERE username=NEW.blocked_user));
       DELETE FROM retweets WHERE (username = NEW.blocked_user AND tweetid IN (SELECT tweetid FROM tweet WHERE username=NEW.username));

       RETURN NEW;
    END IF;

END
$users$ LANGUAGE plpgsql;


CREATE TRIGGER blocked
AFTER INSERT ON block
    FOR EACH ROW EXECUTE PROCEDURE update_blocked();

-------------------------------------------------------------
-- Whenever a tweet is made, the hashtags are extracted and added to the Hashtag table
CREATE OR REPLACE FUNCTION twitter.extracthashtags() RETURNS trigger AS $hashtag$
DECLARE
    regex text;
    content varchar(279);
    htag varchar(279);
BEGIN
    regex := '#(\S+)';
    content := NEW.tweet_content;
    FOR htag IN SELECT regexp_matches(content, regex, 'g') LOOP
        --RAISE NOTICE 'tweetid: % hashtag: %', NEW.tweetid, substring(htag from 2 for (char_length(htag)-2));
        INSERT INTO hashtag VALUES (substring(htag from 2 for (char_length(htag)-2)),NEW.tweetid);
    END LOOP;

      RETURN NEW;
END;
$hashtag$  LANGUAGE plpgsql;


CREATE TRIGGER hashtag
AFTER INSERT ON tweet
    FOR EACH ROW EXECUTE PROCEDURE ExtractHashtags();

--------------------------------------------------------------------------------------------------------------------------