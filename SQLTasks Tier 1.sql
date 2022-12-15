/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

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

/* ANS: */
SELECT name
FROM Facilities
WHERE membercost <> 0.0

/* Q2: How many facilities do not charge a fee to members? */

/* ANS: */
SELECT COUNT(name)
FROM Facilities
WHERE membercost <> 0.0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

/* ANS: */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost <> 0.0 AND membercost < 0.2*monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

/* ANS: */
SELECT *
FROM Facilities
WHERE facid in (1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

/* ANS: */
SELECT name, monthlymaintenance, 
	CASE 
    	WHEN monthlymaintenance > 100 THEN 'expensive'
    	ELSE 'cheap' 
    END AS expense_label
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

/* ANS: */
SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/* ANS: */
SELECT DISTINCT full_name, facility
FROM
(SELECT f.name AS facility, CONCAT(m.firstname, ' ', m.surname) AS full_name
FROM Members as m
INNER JOIN Bookings as b
ON b.memid = m.memid
INNER JOIN Facilities as f
ON f.facid = b.facid
AND f.name IN ('TENNIS COURT 1', 'TENNIS COURT 2')) AS subquery
ORDER BY full_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

/* ANS: */
SELECT f.name AS facility_name, CONCAT(m.firstname, ' ', m.surname) AS full_name,
CASE 
	WHEN m.memid > 0 THEN f.membercost * slots
    ELSE guestcost * slots
END AS cost
FROM Members as m
INNER JOIN Bookings as b
ON b.memid = m.memid
INNER JOIN Facilities as f
ON f.facid = b.facid
WHERE starttime LIKE '2012-09-14%' AND 
(CASE
	WHEN b.memid > 0 THEN membercost * slots > 30
	ELSE guestcost * slots > 30
END)
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

/* ANS: */
SELECT name AS facility_name, CONCAT(firstname, ' ', surname) AS full_name, cost
FROM
(SELECT *,
CASE
	WHEN b.memid > 0 THEN f.membercost * slots
	ELSE f.guestcost * slots
END AS cost
FROM Bookings AS b
INNER JOIN Facilities AS f USING(facid)
INNER JOIN Members AS m USING(memid)
WHERE starttime LIKE '2012-09-14%') AS subquery
WHERE cost > 30
ORDER BY cost DESC;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* ANS: */
SELECT name AS facility_name, SUM(cost) AS revenue 
FROM
(SELECT *,
CASE
	WHEN b.memid > 0 THEN f.membercost * slots
	ELSE f.guestcost * slots
END AS cost
FROM Bookings AS b
INNER JOIN Facilities AS f USING(facid)) AS subquery
GROUP BY facility_name
HAVING revenue < 1000;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

/* ANS: */
SELECT (m1.surname || ', ' || m1.firstname) AS full_name,
CASE
    WHEN m2.memid <> 0 THEN (m2.surname || ', ' || m2.firstname)
END AS recommendedby_name
FROM Members AS m1
INNER JOIN Members AS m2
ON m1.recommendedby = m2.memid
WHERE m1.memid <> 0
ORDER BY full_name;

/* Q12: Find the facilities with their usage by member, but not guests */

/* ANS: note: I'm assuming by usage you mean total number of slots */
SELECT name AS facility_name, (firstname || ' ' || surname) AS full_name, SUM(slots) AS total_usage_per_member_per_facility
FROM Facilities
JOIN Bookings
USING(facid)
JOIN Members
USING(memid)
WHERE memid <> 0
GROUP BY full_name, name;

/* Q13: Find the facilities usage by month, but not guests */

/* ANS: */
SELECT name AS facility_name, strftime('%m', starttime) AS month_number, SUM(slots) AS total_usage_by_month
FROM Facilities
JOIN Bookings
USING(facid)
WHERE memid <> 0
GROUP BY facility_name, month_number;