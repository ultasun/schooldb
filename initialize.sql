-- Initialization file for 'schooldb', a database schema to model the ideal
-- educational information system.  VARCHAR lengths that are powers of 2
-- probably do not have any specific application meaning.
-- See LICENSE for distribution/usage information.
-- Thanks for reading!

-- Need to drop the existing schema if it exists
DROP SCHEMA IF EXISTS `schooldb`;

-- Initialize the schema
CREATE SCHEMA `schooldb`;
USE `schooldb`;

--
-- ****************************
-- ***** begin table creation

-- longest nation name on earth is 74 characters
CREATE TABLE `nations` (
       `nations_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `nations_name` VARCHAR(128) NOT NULL,
       `nations_code` VARCHAR(2) NOT NULL,
       PRIMARY KEY (`nations_id`)
);

-- intermediate between the nation and the cityzip_pair.
-- this will also help if globally, a state or nation has a name change
-- (for example, break-up of the USSR in 1991).  
CREATE TABLE `states` (
       `states_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `states_name` VARCHAR(128) NOT NULL,
       `states_code` VARCHAR(2) NOT NULL,
       `states_nations_id_fk` INT UNSIGNED NOT NULL,
       PRIMARY KEY (`states_id`),
       FOREIGN KEY (`states_nations_id_fk`) REFERENCES nations(`nations_id`)
);

-- longest incorporated city in usa, according to usps, is 23 characters
-- READ https://en.wikipedia.org/wiki/List_of_postal_codes
-- longest consecutive code is 7 digits (Israel)
CREATE TABLE `cityzip_pairs` (
       `cityzip_pairs_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `cityzip_pairs_city` VARCHAR(24) NOT NULL,
       `cityzip_pairs_zipcore` VARCHAR(7) NOT NULL,
       `cityzip_pairs_zipext` VARCHAR(5),
       `cityzip_pairs_states_id_fk` INT UNSIGNED NOT NULL,
       PRIMARY KEY(`cityzip_pairs_id`),
       FOREIGN KEY (`cityzip_pairs_states_id_fk`) REFERENCES states(`states_id`)
);

-- USPS will not accept more than 46 characters on each address line
-- (ups 30 character limit, fedx 35 character limit)
--
-- multiple students and/or faculty members might share a same address
CREATE TABLE `addresses` (
       `addresses_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `addresses_line_1` VARCHAR(46) NOT NULL,
       `addresses_line_2` VARCHAR(46),
       `addresses_cityzip_pairs_fk` INT UNSIGNED NOT NULL,
       -- the next column is TRUE if the address no longer exists
       `addresses_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`addresses_id`),
       FOREIGN KEY (`addresses_cityzip_pairs_fk`)
       REFERENCES cityzip_pairs(`cityzip_pairs_id`)
);

-- some schools like to have multiple brands.
-- allows us to use the entire schema to track a variety of students and
-- instructors across multiple institutions, and do things like building 
-- a database of course equivalancies
CREATE TABLE `institutions` (
       `institutions_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `institutions_legal_name` VARCHAR(128) NOT NULL,
       `institutions_operating_state_fk` INT UNSIGNED NOT NULL,
       `institutions_alt_name` VARCHAR(32),
       `institutions_mailing_fk` INT UNSIGNED NOT NULL,
       `institutions_web_url` LONGTEXT,
       `institutions_has_undergraduate_programs` BOOLEAN NOT NULL,
       `institutions_has_postgraduate_programs` BOOLEAN NOT NULL,
       -- if the next column is TRUE, then the institution is shut down.
       `institutions_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`institutions_id`),
       FOREIGN KEY (`institutions_operating_state_fk`)
       REFERENCES states(`states_id`),
       FOREIGN KEY (`institutions_mailing_fk`)
       REFERENCES addresses(`addresses_id`)
);

-- helps organize grades and services (and their schedules)
CREATE TABLE `semesters` (
       `semesters_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `semesters_name` VARCHAR(32),
       `semesters_start` DATETIME NOT NULL,
       `semesters_finish` DATETIME NOT NULL,
       `semesters_institutions_id_fk` INT UNSIGNED NOT NULL,
       PRIMARY KEY (`semesters_id`),
       FOREIGN KEY (`semesters_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- a person can be both an instructor and student, at one or many schools.
-- if desired to store social security numbers, store the column in this table.
CREATE TABLE `persons` (
       `persons_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `persons_legal_name` VARCHAR(128) NOT NULL,
       `persons_nations_id_fk` INT UNSIGNED NOT NULL,
       -- the next column could be a place to store a social security number
       `persons_national_id` VARCHAR(32),
       `persons_state-issued_id` VARCHAR(32),
       `persons_state-issued_id_states_id_fk` INT UNSIGNED NOT NULL,
       `persons_alt_name` VARCHAR(32),
       `persons_personal_email` VARCHAR(128) NOT NULL,
       `persons_address_1_fk` INT UNSIGNED,
       `persons_address_2_fk` INT UNSIGNED,
       `persons_mailing_address_fk` INT UNSIGNED, 
       `persons_telephone_1` VARCHAR(16),
       `persons_telephone_2` VARCHAR(16),
       `persons_photograph` BLOB,
       -- the next column is TRUE if the person's identity should be disabled.
       `persons_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`persons_id`),
       FOREIGN KEY (`persons_nations_id_fk`) REFERENCES nations(`nations_id`),
       FOREIGN KEY (`persons_state-issued_id_states_id_fk`)
       REFERENCES states(`states_id`),
       FOREIGN KEY (`persons_address_1_fk`)
       REFERENCES addresses(`addresses_id`),
       FOREIGN KEY (`persons_address_2_fk`)
       REFERENCES addresses(`addresses_id`)
);

-- holds basic personnel information about students
CREATE TABLE `students` (
       `students_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `students_persons_id_fk` INT UNSIGNED NOT NULL,
       `students_institutions_id_fk` INT UNSIGNED NOT NULL,
       -- the next column is TRUE if the student is disabled from the system
       `students_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`students_id`),
       FOREIGN KEY (`students_persons_id_fk`) REFERENCES persons(`persons_id`),
       FOREIGN KEY (`students_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- holds basic personnel information about faculty
CREATE TABLE `instructors` (
       `instructors_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `instructors_persons_id_fk` INT UNSIGNED NOT NULL,
       `instructors_institutions_id_fk` INT UNSIGNED NOT NULL,
       `instructors_web_url` LONGTEXT,
       -- the next column is TRUE if the instructor is disabled from the system
       `instructors_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`instructors_id`),
       FOREIGN KEY (`instructors_persons_id_fk`)
       REFERENCES persons(`persons_id`),
       FOREIGN KEY (`instructors_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- similar to instructors table
CREATE TABLE `employees` (
       `employees_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `employees_persons_id_fk` INT UNSIGNED NOT NULL,
       `employees_institutions_id_fk` INT UNSIGNED NOT NULL,
       -- the next column is TRUE if the employee is disabled from the system
       `employees_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`employees_id`),
       FOREIGN KEY (`employees_persons_id_fk`)
       REFERENCES persons(`persons_id`),
       FOREIGN KEY (`employees_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- faculty logins for that institutions computer network
CREATE TABLE `instructor-logins` (
       `instructor-logins_instructors_id` INT UNSIGNED NOT NULL,
       `instructor-logins_institutions_id_fk` INT UNSIGNED NOT NULL,
       `instructor-logins_string` VARCHAR(32) NOT NULL,
       -- the next column is TRUE if the login is disabled
       `instructor-logins_is_defunct` BOOLEAN NOT NULL,
       FOREIGN KEY (`instructor-logins_instructors_id`)
       REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`instructor-logins_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- student logins for that institutions computer network
CREATE TABLE `student-logins` (
       `student-logins_students_id_fk` INT UNSIGNED NOT NULL,
       `student-logins_institutions_id_fk` INT UNSIGNED NOT NULL,
       `student-logins_string` VARCHAR(32) NOT NULL,
       -- the next column is TRUE if the login is disabled
       `student-logins_is_defunct` BOOLEAN NOT NULL,
       FOREIGN KEY (`student-logins_students_id_fk`)
       REFERENCES students(`students_id`),
       FOREIGN KEY (`student-logins_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- employee logins for that institutions computer network
CREATE TABLE `employee-logins` (
       `employee-logins_employees_id_fk` INT UNSIGNED NOT NULL,
       `employee-logins_institutions_id_fk` INT UNSIGNED NOT NULL,
       `employee-logins_string` VARCHAR(32) NOT NULL,
       -- the next column is TRUE If the login is disabled 
       `employee-logins_is_defunct` BOOLEAN NOT NULL,
       FOREIGN KEY (`employee-logins_employees_id_fk`)
       REFERENCES employees(`employees_id`),
       FOREIGN KEY (`employee-logins_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- departments are associated with institutions,
-- and have a chairperson who is an instructor
CREATE TABLE `departments` (
       `depts_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `depts_title` VARCHAR(128) NOT NULL,
       `depts_web_url` LONGTEXT,
       `depts_institutions_id_fk` INT UNSIGNED NOT NULL,
       `depts_chairperson_instructors_fk` INT UNSIGNED NOT NULL,
       -- the next column is TRUE if the department is closed or disabled
       `depts_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`depts_id`),
       FOREIGN KEY (`depts_chairperson_instructors_fk`)
       REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`depts_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- courses are associated with a department, have a number, and have
-- a postgraduate/undergraduate eligibility status
CREATE TABLE `courses` (
       `courses_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `courses_title` VARCHAR(128) NOT NULL,
       `courses_summary` LONGTEXT,
       `courses_credit_hours` DECIMAL(2,1) NOT NULL,
       `courses_depts_id_fk` INT UNSIGNED NOT NULL,
       -- Pearson says some schools use up to 5, might as well use 8
       `courses_number` VARCHAR(8) NOT NULL,
       -- have the ability to store an archive of the course content here
       `courses_content_blob` BLOB,
       -- have the ability to store course content as a large string here 
       `courses_content_clob` LONGTEXT,
       `courses_web_url` LONGTEXT,
       `courses_undergraduates_eligible` BOOLEAN NOT NULL,
       `courses_postgraduates_eligible` BOOLEAN NOT NULL,
       -- if the next column is TRUE then no new course section enrollments
       `courses_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`courses_id`),
       FOREIGN KEY (`courses_depts_id_fk`) REFERENCES departments(`depts_id`)
);

-- links a courses_id to another courses_id, but there is a difference between
-- required and optional courses (on the application side, the user would see
-- that one of any of the optional courses for this course_id_fk has to be
-- completed)
CREATE TABLE `courses-prerequisites` (
       `courses_id_fk` INT UNSIGNED NOT NULL,
       `courses_requires_courses_id_fk` INT UNSIGNED,
       `courses_optional_courses_id_fk` INT UNSIGNED,
       FOREIGN KEY(`courses_id_fk`) REFERENCES courses(`courses_id`),
       FOREIGN KEY(`courses_requires_courses_id_fk`)
       REFERENCES courses(`courses_id`),
       FOREIGN KEY(`courses_optional_courses_id_fk`)
       REFERENCES courses(`courses_id`)
);

-- very similar to courses, except it would be awkward to call a
-- 'Bachelors of Computer Science Program' a course,
-- it is a 'track' or 'degree program'
CREATE TABLE `tracks` (
       `tracks_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `tracks_title` VARCHAR(128) NOT NULL,
       `tracks_web_url` LONGTEXT,
       `tracks_summary` LONGTEXT,
       `tracks_institutions_id_fk` INT UNSIGNED NOT NULL,
       -- if the next two columns are both FALSE, then maybe it's a certificate
       `tracks_is_undergraduate_program` BOOLEAN NOT NULL,
       `tracks_is_postgraduate_program` BOOLEAN NOT NULL,
       -- if the next column is false, then no new students for the track
       `tracks_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`tracks_id`),
       FOREIGN KEY (`tracks_institutions_id_fk`)
       REFERENCES institutions(`institutions_id`)
);

-- very similar to courses-prerequisites
CREATE TABLE `tracks-prerequisites` (
       `tracks-prerequisites_tracks_id_fk` INT UNSIGNED NOT NULL,
       `tracks-prerequisites_requires_courses_id_fk` INT UNSIGNED,
       `tracks-prerequisites_requires_tracks_id_fk` INT UNSIGNED,
       FOREIGN KEY (`tracks-prerequisites_tracks_id_fk`)
       REFERENCES tracks(`tracks_id`),
       FOREIGN KEY (`tracks-prerequisites_requires_courses_id_fk`)
       REFERENCES courses(`courses_id`),
       FOREIGN KEY (`tracks-prerequisites_requires_tracks_id_fk`)
       REFERENCES tracks(`tracks_id`)
);

-- courses equivalency table to help compare course transfer eligibility
-- between institutions
CREATE TABLE `courses-equivalencies` (
       `courses-equivalencies_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `courses-equivalencies_a` INT UNSIGNED NOT NULL,
       `courses-equivalencies_b` INT UNSIGNED NOT NULL,
       PRIMARY KEY (`courses-equivalencies_id`),
       FOREIGN KEY(`courses-equivalencies_a`) REFERENCES courses(`courses_id`),
       FOREIGN KEY(`courses-equivalencies_b`) REFERENCES courses(`courses_id`)
);

-- locations can be nested within other locations, and/or have an
-- addresses_id_fk associated with it.
-- schedules link to locations, because either enrollments or services can
-- link to schedules.
CREATE TABLE `locations` (
       `locations_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `locations_title` VARCHAR(128) NOT NULL,
       -- next column can be NULL if location has a parent location
       `locations_addresses_id_fk` INT UNSIGNED,
       -- next column can be NULL if has addresses_id_fk
       `locations_parent_locations_id_fk` INT UNSIGNED,
       -- next column is TRUE if no new courses may be scheduled here 
       `locations_is_defunct` BOOLEAN NOT NULL,
       PRIMARY KEY (`locations_id`),
       FOREIGN KEY (`locations_addresses_id_fk`)
       REFERENCES addresses(`addresses_id`),
       FOREIGN KEY (`locations_parent_locations_id_fk`)
       REFERENCES locations(`locations_id`)
);

-- this table can allow for a periodic schedule or a fixed one-time event,
-- a schedule must have a semester, although asking which semester we're in
-- is like asking what month it is
CREATE TABLE `schedules` (
       `schedules_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       -- SMTWTFS => 7 days, -M-W-F- => 3 days, can be null if not periodic.
       `schedules_dow` VARCHAR(7),
       -- 24 hour time, no separating colon
       `schedules_start_24hr` VARCHAR(4) NOT NULL,
       -- for example 2345 for 11:45 pm       
       `schedules_end_24hr` VARCHAR(4) NOT NULL,
       `schedules_start` DATETIME NOT NULL,
       `schedules_finish` DATETIME NOT NULL,
       `schedules_meetings_are_virtual` BOOLEAN NOT NULL,
       `schedules_semesters_id_fk` INT UNSIGNED NOT NULL,
       -- if the next column is NULL, then the meeting place is maybe virtual
       `schedules_locations_id_fk` INT UNSIGNED,
       PRIMARY KEY (`schedules_id`),
       FOREIGN KEY (`schedules_semesters_id_fk`)
       REFERENCES semesters(`semesters_id`),
       FOREIGN KEY (`schedules_locations_id_fk`)
       REFERENCES locations(`locations_id`)
);

-- tasks are graded things that students do for points that impact their gpa.
-- note that multiple courses can reference the same task, even at different
-- institutions.
-- (remember a course is bound to an institution, but a task is not)
CREATE TABLE `tasks` (
       `tasks_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `tasks_title` VARCHAR(128) NOT NULL,
       `tasks_summary` LONGTEXT,
       -- the test/project to be interpreted and completed by the student 
       `tasks_content_blob` BLOB,
       -- the test/project to be interpreted and completed by the student
       `tasks_content_clob` LONGTEXT,
       `tasks_max_points_towards_gpa` DECIMAL(6,2) NOT NULL,
       `tasks_points_count_towards_gpa` BOOLEAN NOT NULL,
       PRIMARY KEY (`tasks_id`)
);

-- once you have a passing grade for each task associated with a course,
-- you have passed the course
CREATE TABLE `courses-tasks` (
       `courses-tasks_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `courses-tasks_tasks_id_fk` INT UNSIGNED NOT NULL,
       `courses-tasks_courses_id_fk` INT UNSIGNED NOT NULL,
       `courses-tasks_points_coefficient` DECIMAL(4,2) NOT NULL,
       PRIMARY KEY (`courses-tasks_id`),
       FOREIGN KEY (`courses-tasks_tasks_id_fk`)
       REFERENCES tasks(`tasks_id`),
       FOREIGN KEY (`courses-tasks_courses_id_fk`)
       REFERENCES courses(`courses_id`)
);

-- enrollment table to tell us the schedule so that we can easily calculate
-- the credit hours spent by each student.
-- this table would play a key role in a 'course sections' VIEW.
CREATE TABLE `enrollments` (
       `enrollments_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `enrollments_schedules_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_instructors_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_students_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_courses_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_is_auditing` BOOLEAN NOT NULL,
       PRIMARY KEY (`enrollments_id`),
       FOREIGN KEY (`enrollments_schedules_id_fk`)
       REFERENCES schedules(`schedules_id`),
       FOREIGN KEY (`enrollments_instructors_id_fk`)
       REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`enrollments_students_id_fk`)
       REFERENCES students(`students_id`),
       FOREIGN KEY (`enrollments_courses_id_fk`)
       REFERENCES courses(`courses_id`)
);

-- grades are associated with a specific enrollment,
-- which is an instance of a class, also known as a 'course section'.
CREATE TABLE `grades` (
       `grades_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `grades_enrollments_id_fk` INT UNSIGNED NOT NULL,
       -- need to divide this by the 'tasks_max_points_towards_gpa' in 'tasks'
       `grades_points_towards_gpa` DECIMAL(6,2) NOT NULL,
       `grades_instructors_comments` LONGTEXT,
       `grades_students_comments` LONGTEXT,
       -- the next two columns are the instructor's grading/feedback of the work
       `grades_instructors_attachment_blob` BLOB,
       `grades_instructors_attachment_clob` LONGTEXT,
       `grades_students_attachment_blob` BLOB, -- the student submission
       `grades_students_attachment_clob` LONGTEXT, -- the student submission
       `grades_tasks_id_fk` INT UNSIGNED NOT NULL,
       `grades_date_created` DATETIME NOT NULL,
       `grades_date_last_updated` DATETIME,
       PRIMARY KEY (`grades_id`),
       FOREIGN KEY (`grades_enrollments_id_fk`)
       REFERENCES enrollments(`enrollments_id`),
       FOREIGN KEY (`grades_tasks_id_fk`) REFERENCES tasks(`tasks_id`)
);

-- this could be for custom tutoring hours, graduation ceremonies,
-- or other events which do not have graded tasks or should be considered
-- an enrollment or part of a track.
-- however, because it still has a primary key, it could be billed, and it may
-- appear on schedules. so graduation events, tutoring sessions...
CREATE TABLE `services` (
       `services_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `services_instructors_id_fk` INT UNSIGNED,
       `services_students_id_fk` INT UNSIGNED,
       `services_schedules_id_fk` INT UNSIGNED NOT NULL,
       PRIMARY KEY (`services_id`),
       FOREIGN KEY (`services_instructors_id_fk`)
       REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`services_students_id_fk`)
       REFERENCES students(`students_id`),
       FOREIGN KEY (`services_schedules_id_fk`)
       REFERENCES schedules(`schedules_id`)
);

-- ***** end table creation
-- ****************************
-- ***** begin trigger creation

-- if a person is marked as defunct, then all their roles should be, too.

DELIMITER $$

CREATE TRIGGER defunct_person_defuncts_all_roles AFTER UPDATE ON persons
FOR EACH ROW
BEGIN

UPDATE students, persons SET students.students_is_defunct = TRUE
WHERE students.students_persons_id_fk = persons.persons_id
AND persons.persons_is_defunct = TRUE;

UPDATE instructors, persons SET instructors.instructors_is_defunct = TRUE
WHERE instructors.instructors_persons_id_fk = persons.persons_id
AND persons.persons_is_defunct = TRUE;

UPDATE employees, persons SET employees.employees_is_defunct = TRUE
WHERE employees.employees_persons_id_fk = persons.persons_id
AND persons.persons_is_defunct = TRUE;

END;$$

DELIMITER ;

-- ***** end trigger creation
-- ****************************
-- ***** begin view creation

CREATE VIEW students_legal_names AS
       SELECT students.students_id,
       persons.persons_id, persons.persons_legal_name
       FROM students, persons
       WHERE students.students_persons_id_fk = persons.persons_id;

CREATE VIEW instructors_legal_names AS
       SELECT instructors.instructors_id,
       persons.persons_id, persons.persons_legal_name
       FROM instructors, persons
       WHERE instructors.instructors_persons_id_fk = persons.persons_id;

-- these three views are necessary to do bottega-tasks/01.sql

CREATE VIEW grades_instructors_matrix AS
SELECT grades.grades_points_towards_gpa,
tasks.tasks_max_points_towards_gpa,
instructors.instructors_id,
persons.persons_legal_name,
institutions.institutions_alt_name
FROM
(((instructors
LEFT JOIN enrollments
ON instructors.instructors_id = enrollments.enrollments_instructors_id_fk)
LEFT JOIN grades
ON grades.grades_enrollments_id_fk = enrollments.enrollments_id)
LEFT JOIN tasks
ON grades.grades_tasks_id_fk = tasks.tasks_id), persons, institutions
WHERE instructors.instructors_persons_id_fk = persons.persons_id
AND instructors.instructors_institutions_id_fk = institutions.institutions_id;

CREATE VIEW average_grades_percentage_from_all_instructors AS
SELECT institutions.institutions_alt_name,
persons.persons_legal_name,
((sum(grades_points_towards_gpa) / sum(tasks_max_points_towards_gpa)) * 100) AS
percentage FROM
(grades_instructors_matrix
INNER JOIN instructors
ON grades_instructors_matrix.instructors_id = instructors.instructors_id),
institutions, persons
WHERE instructors.instructors_persons_id_fk = persons.persons_id
AND instructors.instructors_institutions_id_fk = institutions.institutions_id
GROUP BY persons_legal_name, institutions_alt_name;

CREATE VIEW average_grades_assigned_by_instructors AS
SELECT * FROM average_grades_percentage_from_all_instructors
WHERE percentage IS NOT NULL;

-- these two views are necessary to do bottega-tasks/02.sql
-- query script for the top grades for each student

CREATE VIEW grades_for_all_students AS
SELECT persons.persons_legal_name, tasks.tasks_title,
grades.grades_points_towards_gpa, tasks.tasks_max_points_towards_gpa,
((grades.grades_points_towards_gpa/tasks.tasks_max_points_towards_gpa)*100) AS
percentage FROM
(grades LEFT JOIN tasks ON grades.grades_tasks_id_fk = tasks.tasks_id),
enrollments, students, persons
WHERE  grades.grades_enrollments_id_fk = enrollments.enrollments_id
AND grades.grades_tasks_id_fk = tasks.tasks_id
AND enrollments.enrollments_students_id_fk = students.students_id
AND students.students_persons_id_fk = persons.persons_id
ORDER BY percentage;

CREATE VIEW top_grades_for_all_students AS
SELECT DISTINCT persons_legal_name, percentage FROM grades_for_all_students; 

-- this one view is necessary to do bottega-tasks/03.sql

CREATE VIEW all_courses_for_all_students AS
SELECT courses.courses_title AS course,
departments.depts_title AS department,
institutions.institutions_alt_name AS school,
persons.persons_legal_name AS students_name,
schedules.schedules_dow AS schedule,
schedules.schedules_start_24hr AS start_time,
schedules.schedules_end_24hr AS end_time,
x.persons_legal_name AS instructors_name FROM
(SELECT persons_id, persons_legal_name FROM persons RIGHT JOIN instructors ON
persons.persons_id = instructors.instructors_persons_id_fk) AS
x, courses, students,
persons, schedules, instructors, institutions, departments, enrollments
WHERE persons.persons_id = students.students_persons_id_fk
AND institutions.institutions_id = departments.depts_institutions_id_fk
AND courses.courses_depts_id_fk = departments.depts_id
AND courses.courses_id = enrollments.enrollments_courses_id_fk
AND schedules.schedules_id = enrollments.enrollments_schedules_id_fk
AND students.students_id = enrollments.enrollments_students_id_fk
AND instructors.instructors_id = enrollments.enrollments_instructors_id_fk
AND x.persons_id = instructors.instructors_persons_id_fk;

-- these two views are necessary to do bottega-tasks/04.sql

CREATE VIEW grades_for_all_students_2 AS
SELECT persons.persons_legal_name, tasks.tasks_title, courses.courses_title,
grades.grades_points_towards_gpa AS points,
tasks.tasks_max_points_towards_gpa AS max_points
FROM (grades LEFT JOIN tasks ON grades.grades_tasks_id_fk = tasks.tasks_id),
enrollments, students, persons, courses
WHERE grades.grades_enrollments_id_fk = enrollments.enrollments_id
AND grades.grades_tasks_id_fk = tasks.tasks_id
AND enrollments.enrollments_students_id_fk = students.students_id
AND students.students_persons_id_fk = persons.persons_id
AND enrollments.enrollments_courses_id_fk = courses.courses_id;

CREATE VIEW courses_average_grades_sorted AS
SELECT DISTINCT courses_title,
(SELECT (sum(points) / sum(max_points) * 100)
FROM grades_for_all_students_2) AS average_percent
FROM grades_for_all_students_2 order by average_percent asc;

-- this one view is for bottega-tasks/05.sql
-- query script for finding which student AND professor have
-- the most courses in common

CREATE VIEW max_unioned_enrollments AS
SELECT instructors_legal_names.persons_legal_name AS instructors_name,
students_legal_names.persons_legal_name AS students_name,
count1 AS matches_count
FROM instructors_legal_names, students_legal_names, enrollments
LEFT JOIN
(SELECT enrollments.enrollments_students_id_fk,
enrollments.enrollments_instructors_id_fk,
count(enrollments.enrollments_students_id_fk)
AS count1, count(enrollments.enrollments_instructors_id_fk)
AS count2
FROM enrollments
GROUP BY
enrollments.enrollments_instructors_id_fk,
enrollments.enrollments_students_id_fk) AS counter
ON
counter.enrollments_instructors_id_fk=enrollments.enrollments_instructors_id_fk
AND counter.enrollments_students_id_fk = enrollments.enrollments_students_id_fk
WHERE
enrollments.enrollments_instructors_id_fk =
instructors_legal_names.instructors_id
AND enrollments.enrollments_students_id_fk =
students_legal_names.students_id
GROUP BY count2,count1,instructors_legal_names.persons_legal_name,
students_legal_names.persons_legal_name
ORDER BY count1 DESC LIMIT 1;

-- ***** end view creation
-- ****************************

USE `schooldb`
BEGIN;

INSERT INTO `nations` (`nations_name`, `nations_code`) VALUES ('United States', 'US');
INSERT INTO `nations` (`nations_name`, `nations_code`) VALUES ('Mexico', 'MX');
INSERT INTO `nations` (`nations_name`, `nations_code`) VALUES ('Canada', 'CA');
INSERT INTO `nations` (`nations_name`, `nations_code`) VALUES ('United Kingdom', 'UK');
INSERT INTO `nations` (`nations_name`, `nations_code`) VALUES ('Japan', 'JP');
INSERT INTO `nations` (`nations_name`, `nations_code`) VALUES ('Peru', 'PE');

INSERT INTO `states` (`states_name`, `states_code`, `states_nations_id_fk`) VALUES ('Pennsylvania', 'PA', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1));
INSERT INTO `states` (`states_name`, `states_code`, `states_nations_id_fk`) VALUES ('New Jersey', 'NJ', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1));
INSERT INTO `states` (`states_name`, `states_code`, `states_nations_id_fk`) VALUES ('Florida', 'FL', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1));
INSERT INTO `states` (`states_name`, `states_code`, `states_nations_id_fk`) VALUES ('New York', 'NY', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1));
INSERT INTO `states` (`states_name`, `states_code`, `states_nations_id_fk`) VALUES ('Texas', 'TX', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1));

INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('Indianland', '18088', (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1));
INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('Berlinsville', '18088', (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1));
INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('Nesquehoning', '18240', (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1));
INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('Bloomsburg', '17815', (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1));
INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('Tampa', '33609', (SELECT states_id FROM states WHERE states_code = 'FL' LIMIT 1));
INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('Tampa', '33611', (SELECT states_id FROM states WHERE states_code = 'FL' LIMIT 1));
INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('Houston', '77001', (SELECT states_id FROM states WHERE states_code = 'TX' LIMIT 1));

INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('1111 Lehigh Dr', (SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = 'Indianland' AND cityzip_pairs_zipcore = '18088' LIMIT 1), false);
INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('1111 Lake Dr', (SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = 'Nesquehoning' AND cityzip_pairs_zipcore = '18240' LIMIT 1), false);
INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('1111 University Dr', (SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = 'Bloomsburg' AND cityzip_pairs_zipcore = '17815' LIMIT 1), false);
INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('3828 W Platt St', (SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = 'Tampa' AND cityzip_pairs_zipcore = '33609' LIMIT 1), false);
INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('5217 Puritan Ave', (SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = 'Tampa' AND cityzip_pairs_zipcore = '33611' LIMIT 1), false);
INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('1111 Nowhere St', (SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = 'Houston' AND cityzip_pairs_zipcore = '77001' LIMIT 1), false);
INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('1111 Somewhere Pl', (SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = 'Berlinsville' AND cityzip_pairs_zipcore = '18088' LIMIT 1), false);

INSERT INTO `institutions` (`institutions_legal_name`, `institutions_operating_state_fk`, `institutions_alt_name`, `institutions_mailing_fk`, `institutions_web_url`, `institutions_has_undergraduate_programs`, `institutions_has_postgraduate_programs`, `institutions_is_defunct`) VALUES ('Bloomsburg University Of Pennsylvania', (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'BU', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 University Dr' LIMIT 1), 'https://bloomu.edu', true, true, false);

INSERT INTO semesters (`semesters_name`, `semesters_start`, `semesters_finish`, `semesters_institutions_id_fk`) VALUES ('Fall 2021', '2021-09-01 08:00:00', '2021-12-23 21:00:00', (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1));

INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('James Capozzoli', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'manykwh@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 Lehigh Dr' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Mike Mol', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'mikethemol@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 Lake Dr' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Cindy Carma', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'cindycarma@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 University Dr' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Adam Appletosh', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'FL' LIMIT 1), 'adamappletosh@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '3828 W Platt St' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Casey Bro', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'TX' LIMIT 1), 'caseybro@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 Nowhere St' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Margret Mi-yetta', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'margretmi@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 University Dr' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Cassidy Clever', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'cash@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 University Dr' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Yennifer Yaboozle', (SELECT nations_id FROM nations WHERE nations_code = 'PE' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'FL' LIMIT 1), 'yenny@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '5217 Puritan Ave' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Luis Rico', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'FL' LIMIT 1), 'commonname@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '5217 Puritan Ave' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Selina Sikorsky', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'NJ' LIMIT 1), 'helicopter@bearingfailure.com', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 Somewhere Pl' LIMIT 1), true);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Diana Deerbourne', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'propolice@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 University Dr' LIMIT 1), false);
INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('Amy Ante', (SELECT nations_id FROM nations WHERE nations_code = 'US' LIMIT 1), (SELECT states_id FROM states WHERE states_code = 'PA' LIMIT 1), 'drante@localhost', (SELECT addresses_id FROM addresses WHERE addresses_line_1 = '1111 University Dr' LIMIT 1), false);

INSERT INTO students (`students_persons_id_fk`, `students_institutions_id_fk`, `students_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'James Capozzoli' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO students (`students_persons_id_fk`, `students_institutions_id_fk`, `students_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Adam Appletosh' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO students (`students_persons_id_fk`, `students_institutions_id_fk`, `students_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Casey Bro' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO students (`students_persons_id_fk`, `students_institutions_id_fk`, `students_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Yennifer Yaboozle' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO students (`students_persons_id_fk`, `students_institutions_id_fk`, `students_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Luis Rico' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO students (`students_persons_id_fk`, `students_institutions_id_fk`, `students_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Selina Sikorsky' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), true);

INSERT INTO instructors (`instructors_persons_id_fk`, `instructors_institutions_id_fk`, `instructors_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO instructors (`instructors_persons_id_fk`, `instructors_institutions_id_fk`, `instructors_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO instructors (`instructors_persons_id_fk`, `instructors_institutions_id_fk`, `instructors_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Margret Mi-yetta' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO instructors (`instructors_persons_id_fk`, `instructors_institutions_id_fk`, `instructors_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Amy Ante' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);

INSERT INTO employees (`employees_persons_id_fk`, `employees_institutions_id_fk`, `employees_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Mike Mol' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);
INSERT INTO employees (`employees_persons_id_fk`, `employees_institutions_id_fk`, `employees_is_defunct`) VALUES ((SELECT persons_id FROM persons WHERE persons_legal_name = 'Diana Deerbourne' LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), false);

INSERT INTO `instructor-logins` (`instructor-logins_instructors_id`, `instructor-logins_institutions_id_fk`, `instructor-logins_string`, `instructor-logins_is_defunct`) VALUES ((SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'ccarma@bu.notreal', false);
INSERT INTO `instructor-logins` (`instructor-logins_instructors_id`, `instructor-logins_institutions_id_fk`, `instructor-logins_string`, `instructor-logins_is_defunct`) VALUES ((SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'cclever@bu.notreal', false);
INSERT INTO `instructor-logins` (`instructor-logins_instructors_id`, `instructor-logins_institutions_id_fk`, `instructor-logins_string`, `instructor-logins_is_defunct`) VALUES ((SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Margret Mi-yetta' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'miata@bu.notreal', false);
INSERT INTO `instructor-logins` (`instructor-logins_instructors_id`, `instructor-logins_institutions_id_fk`, `instructor-logins_string`, `instructor-logins_is_defunct`) VALUES ((SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Amy Ante' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'aante@bu.notreal', false);

INSERT INTO `student-logins` (`student-logins_students_id_fk`, `student-logins_institutions_id_fk`, `student-logins_string`, `student-logins_is_defunct`) VALUES ((SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'James Capozzoli' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'jac00178@huskies', false);
INSERT INTO `student-logins` (`student-logins_students_id_fk`, `student-logins_institutions_id_fk`, `student-logins_string`, `student-logins_is_defunct`) VALUES ((SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Adam Appletosh' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'aaa01234@huskies', false);
INSERT INTO `student-logins` (`student-logins_students_id_fk`, `student-logins_institutions_id_fk`, `student-logins_string`, `student-logins_is_defunct`) VALUES ((SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Casey Bro' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'ccc01234@huskies', false);
INSERT INTO `student-logins` (`student-logins_students_id_fk`, `student-logins_institutions_id_fk`, `student-logins_string`, `student-logins_is_defunct`) VALUES ((SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Yennifer Yaboozle' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'yyy01234@huskies', false);
INSERT INTO `student-logins` (`student-logins_students_id_fk`, `student-logins_institutions_id_fk`, `student-logins_string`, `student-logins_is_defunct`) VALUES ((SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Luis Rico' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'lr_01234@huskies', false);
INSERT INTO `student-logins` (`student-logins_students_id_fk`, `student-logins_institutions_id_fk`, `student-logins_string`, `student-logins_is_defunct`) VALUES ((SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Selina Sikorsky' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'sss01234@huskies', true);

INSERT INTO `employee-logins` (`employee-logins_employees_id_fk`, `employee-logins_institutions_id_fk`, `employee-logins_string`, `employee-logins_is_defunct`) VALUES ((SELECT employees_id FROM employees WHERE employees_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Mike Mol' LIMIT 1) AND employees_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), 'mikemol@somewhe.re', false);

INSERT INTO departments (`depts_title`, `depts_institutions_id_fk`, `depts_chairperson_instructors_fk`, `depts_is_defunct`) VALUES ('HRM', (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), false);
INSERT INTO departments (`depts_title`, `depts_institutions_id_fk`, `depts_chairperson_instructors_fk`, `depts_is_defunct`) VALUES ('COMPSCI', (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), false);
INSERT INTO departments (`depts_title`, `depts_institutions_id_fk`, `depts_chairperson_instructors_fk`, `depts_is_defunct`) VALUES ('CHEM', (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Margret Mi-yetta' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), false);

INSERT INTO courses (`courses_title`, `courses_credit_hours`, `courses_depts_id_fk`, `courses_number`, `courses_undergraduates_eligible`, `courses_postgraduates_eligible`, `courses_is_defunct`) VALUES ('Customer Service 1', 3.0, (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), '101', true, true, false);
INSERT INTO courses (`courses_title`, `courses_credit_hours`, `courses_depts_id_fk`, `courses_number`, `courses_undergraduates_eligible`, `courses_postgraduates_eligible`, `courses_is_defunct`) VALUES ('Customer Service 2', 3.0, (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), '201', true, true, false);
INSERT INTO courses (`courses_title`, `courses_credit_hours`, `courses_depts_id_fk`, `courses_number`, `courses_undergraduates_eligible`, `courses_postgraduates_eligible`, `courses_is_defunct`) VALUES ('Introduction to Java', 3.0, (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), '101', true, true, false);
INSERT INTO courses (`courses_title`, `courses_credit_hours`, `courses_depts_id_fk`, `courses_number`, `courses_undergraduates_eligible`, `courses_postgraduates_eligible`, `courses_is_defunct`) VALUES ('Database Design I', 3.0, (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), '110', true, true, false);
INSERT INTO courses (`courses_title`, `courses_credit_hours`, `courses_depts_id_fk`, `courses_number`, `courses_undergraduates_eligible`, `courses_postgraduates_eligible`, `courses_is_defunct`) VALUES ('Chemistry Lab for Sciences I', 4.0, (SELECT depts_id FROM departments WHERE depts_title = 'CHEM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), '110', true, false, false);

INSERT INTO `courses-prerequisites` (`courses_id_fk`, `courses_requires_courses_id_fk`) VALUES ((SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 201 LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1));

INSERT INTO tracks (`tracks_title`, `tracks_institutions_id_fk`, `tracks_is_undergraduate_program`, `tracks_is_postgraduate_program`, `tracks_is_defunct`) VALUES ('HRM TRACK', (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), true, true, false);
INSERT INTO tracks (`tracks_title`, `tracks_institutions_id_fk`, `tracks_is_undergraduate_program`, `tracks_is_postgraduate_program`, `tracks_is_defunct`) VALUES ('Computer Science Bachelors', (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1), true, true, false);

INSERT INTO `tracks-prerequisites` (`tracks-prerequisites_tracks_id_fk`, `tracks-prerequisites_requires_courses_id_fk`) VALUES ((SELECT tracks_id FROM tracks WHERE tracks_title = 'HRM TRACK' AND tracks_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 201 LIMIT 1));
INSERT INTO `tracks-prerequisites` (`tracks-prerequisites_tracks_id_fk`, `tracks-prerequisites_requires_courses_id_fk`) VALUES ((SELECT tracks_id FROM tracks WHERE tracks_title = 'Computer Science Bachelors' AND tracks_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1));
INSERT INTO `tracks-prerequisites` (`tracks-prerequisites_tracks_id_fk`, `tracks-prerequisites_requires_courses_id_fk`) VALUES ((SELECT tracks_id FROM tracks WHERE tracks_title = 'Computer Science Bachelors' AND tracks_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 110 LIMIT 1));

INSERT INTO locations (`locations_title`, `locations_is_defunct`) VALUES ('Building A', false);

INSERT INTO schedules (`schedules_start_24hr`, `schedules_end_24hr`, `schedules_dow`, `schedules_start`, `schedules_finish`, `schedules_meetings_are_virtual`, `schedules_semesters_id_fk`) VALUES ('0800', '0950', '-M-W-F-', '2021-09-01 08:00:00', '2021-12-22 09:50:00', false, (SELECT semesters_id FROM semesters WHERE semesters_name = 'Fall 2021' AND semesters_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1));
INSERT INTO schedules (`schedules_start_24hr`, `schedules_end_24hr`, `schedules_dow`, `schedules_start`, `schedules_finish`, `schedules_meetings_are_virtual`, `schedules_semesters_id_fk`) VALUES ('1000', '1150', '-M-W-F-', '2021-09-01 10:00:00', '2021-12-22 11:50:00', false, (SELECT semesters_id FROM semesters WHERE semesters_name = 'Fall 2021' AND semesters_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1));
INSERT INTO schedules (`schedules_start_24hr`, `schedules_end_24hr`, `schedules_dow`, `schedules_start`, `schedules_finish`, `schedules_meetings_are_virtual`, `schedules_semesters_id_fk`) VALUES ('1300', '1450', '-M-W-F-', '2021-09-01 13:00:00', '2021-12-22 14:50:00', false, (SELECT semesters_id FROM semesters WHERE semesters_name = 'Fall 2021' AND semesters_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1));
INSERT INTO schedules (`schedules_start_24hr`, `schedules_end_24hr`, `schedules_dow`, `schedules_start`, `schedules_finish`, `schedules_meetings_are_virtual`, `schedules_semesters_id_fk`) VALUES ('1500', '1650', '-M-W-F-', '2021-09-01 15:00:00', '2021-12-22 16:50:00', false, (SELECT semesters_id FROM semesters WHERE semesters_name = 'Fall 2021' AND semesters_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1));
INSERT INTO schedules (`schedules_start_24hr`, `schedules_end_24hr`, `schedules_dow`, `schedules_start`, `schedules_finish`, `schedules_meetings_are_virtual`, `schedules_semesters_id_fk`) VALUES ('0800', '1045', '--T-T--', '2021-09-02 08:00:00', '2021-12-23 10:45:00', false, (SELECT semesters_id FROM semesters WHERE semesters_name = 'Fall 2021' AND semesters_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1));

INSERT INTO tasks (`tasks_title`, `tasks_max_points_towards_gpa`, `tasks_points_count_towards_gpa`) VALUES ('HRM 101 QUIZ 1', 100, true);
INSERT INTO tasks (`tasks_title`, `tasks_max_points_towards_gpa`, `tasks_points_count_towards_gpa`) VALUES ('HRM 201 QUIZ 1', 100, true);
INSERT INTO tasks (`tasks_title`, `tasks_max_points_towards_gpa`, `tasks_points_count_towards_gpa`) VALUES ('COMPSCI 101 QUIZ 1', 100, true);

INSERT INTO `courses-tasks` (`courses-tasks_tasks_id_fk`, `courses-tasks_courses_id_fk`, `courses-tasks_points_coefficient`) VALUES ((SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 101 QUIZ 1' LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), 1.0);
INSERT INTO `courses-tasks` (`courses-tasks_tasks_id_fk`, `courses-tasks_courses_id_fk`, `courses-tasks_points_coefficient`) VALUES ((SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 201 QUIZ 1' LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), 1.0);
INSERT INTO `courses-tasks` (`courses-tasks_tasks_id_fk`, `courses-tasks_courses_id_fk`, `courses-tasks_points_coefficient`) VALUES ((SELECT tasks_id FROM tasks WHERE tasks_title = 'COMPSCI 101 QUIZ 1' LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), 1.0);

INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'James Capozzoli' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Yennifer Yaboozle' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Adam Appletosh' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Casey Bro' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Luis Rico' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Selina Sikorsky' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'James Capozzoli' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Yennifer Yaboozle' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Adam Appletosh' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Casey Bro' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Luis Rico' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cassidy Clever' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Selina Sikorsky' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'COMPSCI' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 101 LIMIT 1), false);
INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES ((SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '1045' LIMIT 1), (SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Cindy Carma' LIMIT 1) AND instructors_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'James Capozzoli' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1), (SELECT courses_id FROM courses WHERE courses_depts_id_fk = (SELECT depts_id FROM departments WHERE depts_title = 'HRM' AND depts_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) AND courses_number = 201 LIMIT 1), true);

INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'James Capozzoli' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 101 QUIZ 1' LIMIT 1), '2021-09-05 08:00:00', '2021-09-08 21:00:00');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Yennifer Yaboozle' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 101 QUIZ 1' LIMIT 1), '2021-09-05 08:00:00', '2021-09-08 21:00:00');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Adam Appletosh' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 101 QUIZ 1' LIMIT 1), '2021-09-05 08:00:00', '2021-09-08 21:00:00');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Casey Bro' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 101 QUIZ 1' LIMIT 1), '2021-09-05 08:00:00', '2021-09-08 21:00:00');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Luis Rico' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 101 QUIZ 1' LIMIT 1), '2021-09-05 08:00:00', '2021-09-08 21:00:00');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '0800' AND schedules_end_24hr = '0950' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Selina Sikorsky' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'HRM 101 QUIZ 1' LIMIT 1), '2021-09-05 08:00:00', '2021-09-08 21:00:00');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'James Capozzoli' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'COMPSCI 101 QUIZ 1' LIMIT 1), '2021-09-05 10:00:00', '2021-09-08 21:09:33');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Yennifer Yaboozle' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'COMPSCI 101 QUIZ 1' LIMIT 1), '2021-09-05 10:00:00', '2021-09-08 21:09:31');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Adam Appletosh' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'COMPSCI 101 QUIZ 1' LIMIT 1), '2021-09-05 10:00:00', '2021-09-08 21:09:30');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Casey Bro' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'COMPSCI 101 QUIZ 1' LIMIT 1), '2021-09-05 10:00:00', '2021-09-08 21:09:32');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Luis Rico' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'COMPSCI 101 QUIZ 1' LIMIT 1), '2021-09-05 10:00:00', '2021-09-08 21:09:38');
INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES ((SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = (SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '1000' AND schedules_end_24hr = '1150' LIMIT 1) AND enrollments_students_id_fk = (SELECT students_id FROM students WHERE students_persons_id_fk = (SELECT persons_id FROM persons WHERE persons_legal_name = 'Selina Sikorsky' LIMIT 1) AND students_institutions_id_fk = (SELECT institutions_id FROM institutions WHERE institutions_alt_name = 'BU' LIMIT 1) LIMIT 1) LIMIT 1), 100.00, (SELECT tasks_id FROM tasks WHERE tasks_title = 'COMPSCI 101 QUIZ 1' LIMIT 1), '2021-09-05 10:00:00', '2021-09-08 21:09:35');



COMMIT;
