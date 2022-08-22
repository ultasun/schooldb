-- Initialization file for 'schooldb', a database schema to model the ideal educational
-- information system.  VARCHAR lengths that are powers of 2 probably do not have any
-- specific application meaning.  See LICENSE for distribution/usage information.
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
-- hoping to be as efficient as possible, and we do not want alterations stored in
-- another table (for example, 'USA' vs 'US')
CREATE TABLE `nations` (
       `nations_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `nations_name` VARCHAR(128) NOT NULL,
       `nations_code` VARCHAR(2) NOT NULL,
       PRIMARY KEY (`nations_id`)
);

-- intermediate between the nation and the cityzip_pair. this will also help if globally
-- a state or nation has a name change (for example, break-up of the USSR in 1991).  
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

-- USPS will not accept more than 46 on each address line anyway (ups 30 fedx 35)
CREATE TABLE `addresses` (
       `addresses_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `addresses_line_1` VARCHAR(46) NOT NULL,
       `addresses_line_2` VARCHAR(46),
       `addresses_cityzip_pairs_fk` INT UNSIGNED NOT NULL,
       `addresses_is_defunct` BOOLEAN NOT NULL, -- if the address no longer physically exists
       PRIMARY KEY (`addresses_id`),
       FOREIGN KEY (`addresses_cityzip_pairs_fk`) REFERENCES cityzip_pairs(`cityzip_pairs_id`)
);

-- some schools like to have multiple brands. also this allows us to use the entire schema to track
-- a variety of students/instructors across multiple institutions (not just one!), and do things like build a
-- database of course equivalancies
CREATE TABLE `institutions` (
       `institutions_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `institutions_legal_name` VARCHAR(128) NOT NULL,
       `institutions_operating_state_fk` INT UNSIGNED NOT NULL, -- usually important for tutition cost calculations
       `institutions_alt_name` VARCHAR(32),
       `institutions_mailing_fk` INT UNSIGNED NOT NULL,
       `institutions_web_url` LONGTEXT,
       `institutions_has_undergraduate_programs` BOOLEAN NOT NULL,
       `institutions_has_postgraduate_programs` BOOLEAN NOT NULL,
       `institutions_is_defunct` BOOLEAN NOT NULL, -- is the entire institution no longer active?
       PRIMARY KEY (`institutions_id`),
       FOREIGN KEY (`institutions_operating_state_fk`) REFERENCES states(`states_id`),
       FOREIGN KEY (`institutions_mailing_fk`) REFERENCES addresses(`addresses_id`)
);

-- helps organize grades and services (and their schedules)
CREATE TABLE `semesters` (
       `semesters_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `semesters_name` VARCHAR(32),
       `semesters_start` DATETIME NOT NULL,
       `semesters_finish` DATETIME NOT NULL,
       `semesters_institutions_id_fk` INT UNSIGNED NOT NULL,
       PRIMARY KEY (`semesters_id`),
       FOREIGN KEY (`semesters_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- a person can be both an instructor at one school and a student at another, if we were to collect social security numbers,
-- then they would be stored here
CREATE TABLE `persons` (
       `persons_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `persons_legal_name` VARCHAR(128) NOT NULL,
       `persons_nations_id_fk` INT UNSIGNED NOT NULL, -- the persons nationality is important for residency purposes
       `persons_national_id` VARCHAR(32),
       `persons_state-issued_id` VARCHAR(32),
       `persons_state-issued_id_states_id_fk` INT UNSIGNED NOT NULL, -- colleges take state residency seriously
       `persons_alt_name` VARCHAR(32),
       `persons_personal_email` VARCHAR(128) NOT NULL, -- we need a personal email for basic correspondance
       `persons_address_1_fk` INT UNSIGNED,
       `persons_address_2_fk` INT UNSIGNED,
       `persons_mailing_address_fk` INT UNSIGNED, 
       `persons_telephone_1` VARCHAR(16),
       `persons_telephone_2` VARCHAR(16),
       `persons_photograph` BLOB,
       `persons_is_defunct` BOOLEAN NOT NULL, -- is the person deceased or otherwise no longer active (due to fraud/id-theft etc.)
       PRIMARY KEY (`persons_id`),
       FOREIGN KEY (`persons_nations_id_fk`) REFERENCES nations(`nations_id`),
       FOREIGN KEY (`persons_state-issued_id_states_id_fk`) REFERENCES states(`states_id`),
       FOREIGN KEY (`persons_address_1_fk`) REFERENCES addresses(`addresses_id`),
       FOREIGN KEY (`persons_address_2_fk`) REFERENCES addresses(`addresses_id`)
);

-- holds basic personnel information about students
CREATE TABLE `students` (
       `students_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `students_persons_id_fk` INT UNSIGNED NOT NULL,
       `students_institutions_id_fk` INT UNSIGNED NOT NULL,
       `students_is_defunct` BOOLEAN NOT NULL, -- is the student no longer active?
       PRIMARY KEY (`students_id`),
       FOREIGN KEY (`students_persons_id_fk`) REFERENCES persons(`persons_id`),
       FOREIGN KEY (`students_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- similar to the students table, holds basic personnel information about faculty
CREATE TABLE `instructors` (
       `instructors_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `instructors_persons_id_fk` INT UNSIGNED NOT NULL,
       `instructors_institutions_id_fk` INT UNSIGNED NOT NULL,
       `instructors_web_url` LONGTEXT,
       `instructors_is_defunct` BOOLEAN NOT NULL, -- is the instructor no longer active?
       PRIMARY KEY (`instructors_id`),
       FOREIGN KEY (`instructors_persons_id_fk`) REFERENCES persons(`persons_id`),
       FOREIGN KEY (`instructors_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- similar to instructors table
CREATE TABLE `employees` (
       `employees_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `employees_persons_id_fk` INT UNSIGNED NOT NULL,
       `employees_institutions_id_fk` INT UNSIGNED NOT NULL,
       `employees_is_defunct` BOOLEAN NOT NULL, -- is the employee no longer active?
       PRIMARY KEY (`employees_id`),
       FOREIGN KEY (`employees_persons_id_fk`) REFERENCES persons(`persons_id`),
       FOREIGN KEY (`employees_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- faculty logins for that institutions computer network
CREATE TABLE `instructor-logins` (
       `instructor-logins_instructors_id` INT UNSIGNED NOT NULL,
       `instructor-logins_institutions_id_fk` INT UNSIGNED NOT NULL,
       `instructor-logins_string` VARCHAR(32) NOT NULL,
       `instructor-logins_is_defunct` BOOLEAN NOT NULL, -- is the login/email no longer active?
       FOREIGN KEY (`instructor-logins_instructors_id`) REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`instructor-logins_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- student logins for that institutions computer network
CREATE TABLE `student-logins` (
       `student-logins_students_id_fk` INT UNSIGNED NOT NULL,
       `student-logins_institutions_id_fk` INT UNSIGNED NOT NULL,
       `student-logins_string` VARCHAR(32) NOT NULL,
       `student-logins_is_defunct` BOOLEAN NOT NULL, -- is the login/email no longer active?
       FOREIGN KEY (`student-logins_students_id_fk`) REFERENCES students(`students_id`),
       FOREIGN KEY (`student-logins_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- employee logins for that institutions computer network
CREATE TABLE `employee-logins` (
       `employee-logins_employees_id_fk` INT UNSIGNED NOT NULL,
       `employee-logins_institutions_id_fk` INT UNSIGNED NOT NULL,
       `employee-logins_string` VARCHAR(32) NOT NULL,
       `employee-logins_is_defunct` BOOLEAN NOT NULL, -- is the login/email no longer active?
       FOREIGN KEY (`employee-logins_employees_id_fk`) REFERENCES employees(`employees_id`),
       FOREIGN KEY (`employee-logins_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- departments are associated with institutions, and have a chairperson who is an instructor
CREATE TABLE `departments` (
       `depts_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `depts_title` VARCHAR(128) NOT NULL,
       `depts_web_url` LONGTEXT,
       `depts_institutions_id_fk` INT UNSIGNED NOT NULL,
       `depts_chairperson_instructors_fk` INT UNSIGNED NOT NULL,
       `depts_is_defunct` BOOLEAN NOT NULL, -- is the deptartment obsolete and no longer active?
       PRIMARY KEY (`depts_id`),
       FOREIGN KEY (`depts_chairperson_instructors_fk`) REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`depts_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- courses are associated with a department, and have a number, and a postgraduate/undergraduate eligibility status
CREATE TABLE `courses` (
       `courses_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `courses_title` VARCHAR(128) NOT NULL,
       `courses_summary` LONGTEXT,
       `courses_credit_hours` DECIMAL(2,1) NOT NULL, -- there should not be a course with more than 9 hours earned
       `courses_depts_id_fk` INT UNSIGNED NOT NULL,
       `courses_number` VARCHAR(8) NOT NULL, -- Pearson says some schools use up to 5, might as well use 8
       `courses_content_blob` BLOB, -- there is an argument for storing an archive of the content in the db,
       `courses_content_clob` LONGTEXT, -- years could go by and the normal outlets might become defunct
       `courses_web_url` LONGTEXT,
       `courses_undergraduates_eligible` BOOLEAN NOT NULL,
       `courses_postgraduates_eligible` BOOLEAN NOT NULL,
       `courses_is_defunct` BOOLEAN NOT NULL, -- is the course obsolete and no longer available to new students?
       PRIMARY KEY (`courses_id`),
       FOREIGN KEY (`courses_depts_id_fk`) REFERENCES departments(`depts_id`)
);

-- links a courses_id to another courses_id, but there is a difference between required and optional
-- courses (on the application side, the user would see that one of any of the optional courses for this
-- course_id_fk has to be completed)
CREATE TABLE `courses-prerequisites` (
       `courses_id_fk` INT UNSIGNED NOT NULL,
       `courses_requires_courses_id_fk` INT UNSIGNED,
       `courses_optional_courses_id_fk` INT UNSIGNED,
       FOREIGN KEY(`courses_id_fk`) REFERENCES courses(`courses_id`),
       FOREIGN KEY(`courses_requires_courses_id_fk`) REFERENCES courses(`courses_id`),
       FOREIGN KEY(`courses_optional_courses_id_fk`) REFERENCES courses(`courses_id`)
);

-- very similar to courses, except it would be awkward to call a 'Bachelors of Computer Science Program' a course,
-- it is a 'track' or 'program'
CREATE TABLE `tracks` (
       `tracks_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `tracks_title` VARCHAR(128) NOT NULL,
       `tracks_web_url` LONGTEXT,
       `tracks_summary` LONGTEXT,
       `tracks_institutions_id_fk` INT UNSIGNED NOT NULL,
       `tracks_is_undergraduate_program` BOOLEAN NOT NULL, -- if both of these are false, then the 
       `tracks_is_postgraduate_program` BOOLEAN NOT NULL, -- 'track' is likely a certificate program
       `tracks_is_defunct` BOOLEAN NOT NULL, -- is the track obsolete and no longer available to new students?
       PRIMARY KEY (`tracks_id`),
       FOREIGN KEY (`tracks_institutions_id_fk`) REFERENCES institutions(`institutions_id`)
);

-- very similar to courses-prerequisites
CREATE TABLE `tracks-prerequisites` (
       `tracks-prerequisites_tracks_id_fk` INT UNSIGNED NOT NULL,
       `tracks-prerequisites_requires_courses_id_fk` INT UNSIGNED,
       `tracks-prerequisites_requires_tracks_id_fk` INT UNSIGNED,
       FOREIGN KEY (`tracks-prerequisites_tracks_id_fk`) REFERENCES tracks(`tracks_id`),
       FOREIGN KEY (`tracks-prerequisites_requires_courses_id_fk`) REFERENCES courses(`courses_id`),
       FOREIGN KEY (`tracks-prerequisites_requires_tracks_id_fk`) REFERENCES tracks(`tracks_id`)
);

-- courses equivalency table to help compare course transfer eligibility between institutions
CREATE TABLE `courses-equivalencies` (
       `courses-equivalencies_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `courses-equivalencies_a` INT UNSIGNED NOT NULL,
       `courses-equivalencies_b` INT UNSIGNED NOT NULL,
       PRIMARY KEY (`courses-equivalencies_id`),
       FOREIGN KEY(`courses-equivalencies_a`) REFERENCES courses(`courses_id`),
       FOREIGN KEY(`courses-equivalencies_b`) REFERENCES courses(`courses_id`)
);

-- locations can be nested within other locations, and/or have an addresses_id_fk associated with it
-- schedules link to locations, because either enrollments or services can link to schedules
CREATE TABLE `locations` (
       `locations_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `locations_title` VARCHAR(128) NOT NULL,
       `locations_addresses_id_fk` INT UNSIGNED, -- can be null if location instead has parent location
       `locations_parent_locations_id_fk` INT UNSIGNED, -- can be null if has addresses_id_fk
       `locations_is_defunct` BOOLEAN NOT NULL, -- if the location no longer physically exists
       PRIMARY KEY (`locations_id`),
       FOREIGN KEY (`locations_addresses_id_fk`) REFERENCES addresses(`addresses_id`),
       FOREIGN KEY (`locations_parent_locations_id_fk`) REFERENCES locations(`locations_id`)
);

-- this table can allow for a periodic schedule or a fixed one-time event,
-- a schedule must have a semester, although asking which semester we're in is like asking what month it is
CREATE TABLE `schedules` (
       `schedules_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `schedules_dow` VARCHAR(7), -- SMTWTFS => 7 days, -M-W-F- => 3 days, etc., can be null if not periodic
       `schedules_start_24hr` VARCHAR(4) NOT NULL, -- for example 1945 for 7:45 pm
       `schedules_end_24hr` VARCHAR(4) NOT NULL, -- for example 2345 for 11:45 pm
       `schedules_start` DATETIME NOT NULL,
       `schedules_finish` DATETIME NOT NULL,
       `schedules_meetings_are_virtual` BOOLEAN NOT NULL,
       `schedules_semesters_id_fk` INT UNSIGNED NOT NULL,
       `schedules_locations_id_fk` INT UNSIGNED, -- may be null because it might have virtual meetings
       PRIMARY KEY (`schedules_id`),
       FOREIGN KEY (`schedules_semesters_id_fk`) REFERENCES semesters(`semesters_id`),
       FOREIGN KEY (`schedules_locations_id_fk`) REFERENCES locations(`locations_id`)
);

-- tasks are graded things that students do for points that impact their gpa.
-- note that multiple courses can reference the same task, even at different institutions.
-- (remember a course is bound to an institution, but a task is not)
CREATE TABLE `tasks` (
       `tasks_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `tasks_title` VARCHAR(128) NOT NULL,
       `tasks_summary` LONGTEXT,
       `tasks_content_blob` BLOB, -- the test/project/assignment to be interpreted and completed by the student
       `tasks_content_clob` LONGTEXT,
       `tasks_max_points_towards_gpa` DECIMAL(6,2) NOT NULL,
       `tasks_points_count_towards_gpa` BOOLEAN NOT NULL,
       PRIMARY KEY (`tasks_id`)
);

-- once you have a passing grade for each task associated with a course, you have passed the course
CREATE TABLE `courses-tasks` (
       `courses-tasks_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `courses-tasks_tasks_id_fk` INT UNSIGNED NOT NULL,
       `courses-tasks_courses_id_fk` INT UNSIGNED NOT NULL,
       `courses-tasks_points_coefficient` DECIMAL(4,2) NOT NULL, -- if you have to adapt by more than 10^4 then your GPA scoring is wak
       PRIMARY KEY (`courses-tasks_id`),
       FOREIGN KEY (`courses-tasks_tasks_id_fk`) REFERENCES tasks(`tasks_id`),
       FOREIGN KEY (`courses-tasks_courses_id_fk`) REFERENCES courses(`courses_id`)
);

-- enrollment table to tell us the schedule so that we can easily calculate the credit hours spent by each student
CREATE TABLE `enrollments` (
       `enrollments_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `enrollments_schedules_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_instructors_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_students_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_courses_id_fk` INT UNSIGNED NOT NULL,
       `enrollments_is_auditing` BOOLEAN NOT NULL,
       PRIMARY KEY (`enrollments_id`),
       FOREIGN KEY (`enrollments_schedules_id_fk`) REFERENCES schedules(`schedules_id`),
       FOREIGN KEY (`enrollments_instructors_id_fk`) REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`enrollments_students_id_fk`) REFERENCES students(`students_id`),
       FOREIGN KEY (`enrollments_courses_id_fk`) REFERENCES courses(`courses_id`)
);

-- grades are associated with a specific enrollment, which is an instance of a class
CREATE TABLE `grades` (
       `grades_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `grades_enrollments_id_fk` INT UNSIGNED NOT NULL,
       `grades_points_towards_gpa` DECIMAL(6,2) NOT NULL, -- need to divide this by the 'tasks_max_points_towards_gpa' in 'tasks'
       `grades_instructors_comments` LONGTEXT,
       `grades_students_comments` LONGTEXT,
       `grades_instructors_attachment_blob` BLOB, -- instructor feedback after student submission
       `grades_instructors_attachment_clob` LONGTEXT, -- this is for feedback, not an original 'prompt' to be given to student
       `grades_students_attachment_blob` BLOB, -- the student submission
       `grades_students_attachment_clob` LONGTEXT, -- the student submission
       `grades_tasks_id_fk` INT UNSIGNED NOT NULL,
       `grades_date_created` DATETIME NOT NULL,
       `grades_date_last_updated` DATETIME,
       PRIMARY KEY (`grades_id`),
       FOREIGN KEY (`grades_enrollments_id_fk`) REFERENCES enrollments(`enrollments_id`),
       FOREIGN KEY (`grades_tasks_id_fk`) REFERENCES tasks(`tasks_id`)
);

-- this could be for custom tutoring hours, graduation ceremonies, or other events
-- that otherwise do not have graded tasks or should be considered an enrollment.
-- however, because it still has a primary key, it could be billed
CREATE TABLE `services` (
       `services_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
       `services_instructors_id_fk` INT UNSIGNED,
       `services_students_id_fk` INT UNSIGNED,
       `services_schedules_id_fk` INT UNSIGNED NOT NULL,
       PRIMARY KEY (`services_id`),
       FOREIGN KEY (`services_instructors_id_fk`) REFERENCES instructors(`instructors_id`),
       FOREIGN KEY (`services_students_id_fk`) REFERENCES students(`students_id`),
       FOREIGN KEY (`services_schedules_id_fk`) REFERENCES schedules(`schedules_id`)
);

-- ***** end table creation
-- ****************************
-- ***** begin view creation

-- these are important views so they are styled well

CREATE VIEW students_legal_names AS
       SELECT students.students_id, persons.persons_id, persons.persons_legal_name
       FROM students, persons
       WHERE students.students_persons_id_fk = persons.persons_id;
CREATE VIEW instructors_legal_names AS
       SELECT instructors.instructors_id, persons.persons_id, persons.persons_legal_name
       FROM instructors, persons
       WHERE instructors.instructors_persons_id_fk = persons.persons_id;

-- these three views are necessary to do bottega-tasks/01.sql
drop view if exists grades_instructors_matrix;
create view grades_instructors_matrix as select grades.grades_points_towards_gpa, tasks.tasks_max_points_towards_gpa, instructors.instructors_id, persons.persons_legal_name, institutions.institutions_alt_name FROM (((instructors LEFT JOIN enrollments ON instructors.instructors_id = enrollments.enrollments_instructors_id_fk) LEFT JOIN grades ON grades.grades_enrollments_id_fk = enrollments.enrollments_id) LEFT JOIN tasks ON grades.grades_tasks_id_fk = tasks.tasks_id), persons, institutions where instructors.instructors_persons_id_fk = persons.persons_id and instructors.instructors_institutions_id_fk = institutions.institutions_id;

drop view if exists average_grades_percentages_from_all_instructors;
create view average_grades_percentage_from_all_instructors as select institutions.institutions_alt_name, persons.persons_legal_name, ((sum(grades_points_towards_gpa) / sum(tasks_max_points_towards_gpa)) * 100) as percentage from (grades_instructors_matrix inner join instructors on grades_instructors_matrix.instructors_id = instructors.instructors_id), institutions, persons where instructors.instructors_persons_id_fk = persons.persons_id and instructors.instructors_institutions_id_fk = institutions.institutions_id group by persons_legal_name, institutions_alt_name;

drop view if exists average_grades_assigned_by_instructors;
create view average_grades_assigned_by_instructors as select * from average_grades_percentage_from_all_instructors where percentage is not null;

-- these two views are necessary to do bottega-tasks/02.sql
-- query script for the top grades for each student
drop view if exists grades_for_all_students;
create view grades_for_all_students as select persons.persons_legal_name, tasks.tasks_title, grades.grades_points_towards_gpa, tasks.tasks_max_points_towards_gpa, ((grades.grades_points_towards_gpa/tasks.tasks_max_points_towards_gpa)*100) as percentage from (grades left join tasks on grades.grades_tasks_id_fk = tasks.tasks_id), enrollments, students, persons where grades.grades_enrollments_id_fk = enrollments.enrollments_id and grades.grades_tasks_id_fk = tasks.tasks_id and enrollments.enrollments_students_id_fk = students.students_id and students.students_persons_id_fk = persons.persons_id order by percentage;

drop view if exists top_grades_for_all_students;
create view top_grades_for_all_students as select distinct persons_legal_name, percentage from grades_for_all_students; 

-- this one view is necessary to do bottega-tasks/03.sql
drop view if exists all_courses_for_all_students;
create view all_courses_for_all_students as select courses.courses_title as course, departments.depts_title as department, institutions.institutions_alt_name as school, persons.persons_legal_name as students_name, schedules.schedules_dow as schedule, schedules.schedules_start_24hr as start_time, schedules.schedules_end_24hr as end_time, x.persons_legal_name as instructors_name from (select persons_id, persons_legal_name from persons right join instructors on persons.persons_id = instructors.instructors_persons_id_fk) as x, courses, students, persons, schedules, instructors, institutions, departments, enrollments where persons.persons_id = students.students_persons_id_fk and institutions.institutions_id = departments.depts_institutions_id_fk and courses.courses_depts_id_fk = departments.depts_id and courses.courses_id = enrollments.enrollments_courses_id_fk and schedules.schedules_id = enrollments.enrollments_schedules_id_fk and students.students_id = enrollments.enrollments_students_id_fk and instructors.instructors_id = enrollments.enrollments_instructors_id_fk and x.persons_id = instructors.instructors_persons_id_fk;

-- these two views are necessary to do bottega-tasks/04.sql
drop view if exists grades_for_all_students_2;
create view grades_for_all_students_2 as select persons.persons_legal_name, tasks.tasks_title, courses.courses_title, grades.grades_points_towards_gpa as points, tasks.tasks_max_points_towards_gpa as max_points from (grades left join tasks on grades.grades_tasks_id_fk = tasks.tasks_id), enrollments, students, persons, courses where grades.grades_enrollments_id_fk = enrollments.enrollments_id and grades.grades_tasks_id_fk = tasks.tasks_id and enrollments.enrollments_students_id_fk = students.students_id and students.students_persons_id_fk = persons.persons_id and enrollments.enrollments_courses_id_fk = courses.courses_id;

drop view if exists courses_average_grades_sorted;
create view courses_average_grades_sorted as select distinct courses_title, (select (sum(points) / sum(max_points) * 100) from grades_for_all_students_2) as average_percent from grades_for_all_students_2 order by average_percent asc;

-- this one view is for bottega-tasks/05.sql
-- query script for finding which student and professor have the most courses in common
drop view if exists max_unioned_enrollments;
create view max_unioned_enrollments as select instructors_legal_names.persons_legal_name as instructors_name, students_legal_names.persons_legal_name as students_name, count1 as matches_count from instructors_legal_names, students_legal_names, enrollments left join (select enrollments.enrollments_students_id_fk, enrollments.enrollments_instructors_id_fk, count(enrollments.enrollments_students_id_fk) as count1, count(enrollments.enrollments_instructors_id_fk) as count2 from enrollments group by enrollments.enrollments_instructors_id_fk,enrollments.enrollments_students_id_fk) as counter on counter.enrollments_instructors_id_fk = enrollments.enrollments_instructors_id_fk and counter.enrollments_students_id_fk = enrollments.enrollments_students_id_fk where enrollments.enrollments_instructors_id_fk = instructors_legal_names.instructors_id and enrollments.enrollments_students_id_fk = students_legal_names.students_id group by count2,count1,instructors_legal_names.persons_legal_name,students_legal_names.persons_legal_name order by count1 desc limit 1;

-- ***** end view creation
-- ****************************
--
