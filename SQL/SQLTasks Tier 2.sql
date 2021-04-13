/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM  `Facilities` 
WHERE membercost >0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( name ) 
FROM  `Facilities` 
WHERE membercost =0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost >0
AND 0.2*monthlymaintenance > membercost

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance >100
THEN  'expensive'
ELSE  'cheap'
END AS cost
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM Members
ORDER BY joindate DESC
LIMIT 2

Without LIMIT: 

SELECT firstname, surname, joindate 
FROM Members m
WHERE (
    (joindate = 
    (SELECT MAX(joindate) 
    FROM Members
    WHERE joindate = 
    	(SELECT MAX(joindate) 
         FROM Members)))
	OR
	(joindate = 
    (SELECT MAX(joindate) 
    FROM Members
    WHERE joindate < 
    	(SELECT MAX(joindate) 
         FROM Members))))
ORDER BY joindate DESC

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT name, CONCAT( firstname,  " ", surname ) 
FROM Bookings AS b
LEFT JOIN Facilities AS f
USING ( facid ) 
LEFT JOIN Members AS m
USING ( memid ) 
WHERE facid
IN ( 0, 1 ) 
ORDER BY firstname

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT bookid, name, CONCAT(firstname, " ", surname) AS membername, CASE WHEN memid = 0 THEN guestcost ELSE membercost END AS cost
FROM Bookings
LEFT JOIN Facilities AS f
USING(facid)
LEFT JOIN Members
USING(memid)
WHERE ((starttime LIKE '2012-09-14%')
       AND 
       ((memid = 0 AND guestcost > 30) OR (memid >0 AND membercost >30)))

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

Select name, CONCAT(firstname, " ", surname) AS membername, j.cost 
FROM
(SELECT name, memid, CASE WHEN a.memid = 0 THEN guestcost ELSE membercost END AS cost
 FROM
 (SELECT 
 starttime, 
 facid, 
 memid
 FROM Bookings
 WHERE ((starttime LIKE '2012-09-14%') )) a
	INNER JOIN Facilities f
	ON f.facid = a.facid
	AND ((memid = 0 AND guestcost>30) OR (memid>0 AND membercost >30))) j
INNER JOIN Members m
ON m.memid=j.memid
ORDER BY cost DESC

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name, n.revenue
FROM (

SELECT facid, SUM( j.cost ) AS revenue
FROM (
(

SELECT name, a.facid, memid, 
CASE WHEN a.memid =0
THEN guestcost
ELSE membercost
END AS cost
FROM (

SELECT facid, memid
FROM Bookings
)a
LEFT JOIN Facilities f ON f.facid = a.facid
)j
)
GROUP BY name
) AS n
INNER JOIN Facilities f ON f.facid = n.facid
WHERE revenue >1000
ORDER BY revenue

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.firstname,  m1.surname, m2.firstname, m2.surname
FROM Members as m1
LEFT JOIN Members as m2
ON m1.recommendedby = m2.memid
WHERE m1.recommendedby > 0
ORDER BY m1.surname, m1.firstname

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT name, COUNT(b.memid) AS membookings
FROM Bookings b
LEFT JOIN Facilities f
ON b.facid = f.facid
WHERE memid>0
GROUP BY name

/* Q13: Find the facilities usage by month, but not guests */

SELECT name, CASE WHEN MONTH(starttime)=7 THEN 'July' WHEN MONTH(starttime)=8 THEN 'August' WHEN MONTH(starttime)=9 THEN 'September' ELSE 'Other' END AS month, COUNT(b.memid) AS member_monthly_usage
FROM Bookings b
LEFT JOIN Facilities f
ON b.facid = f.facid
WHERE memid>0
GROUP BY MONTH(starttime), name
ORDER BY name, starttime
(edited in python code to use sqlite datetime function)