# might be nice to order this template in accordance with the dial prefix
def generate_nations(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `nations` (`nations_name`, `nations_code`) VALUES ('"+ x[0] +"', '" + x[1] + "');\n"
    return stringResult

# no newline or semi-colon at the end of the string
def get_nations_id(nation_code):
    return "(SELECT nations_id FROM nations WHERE nations_code = '" + nation_code + "' LIMIT 1)"

def generate_states(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `states` (`states_name`, `states_code`, `states_nations_id_fk`) VALUES ('" + x[0] + "', '" + x[1] + "', " + x[2] + ");\n"
    return stringResult;

def get_states_id(states_code):
    return "(SELECT states_id FROM states WHERE states_code = '" + states_code + "' LIMIT 1)"

def generate_cityzip_pairs(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `cityzip_pairs` (`cityzip_pairs_city`, `cityzip_pairs_zipcore`, `cityzip_pairs_states_id_fk`) VALUES ('" + x[0] + "', '" + x[1] + "', " + x[2] + ");\n"
    return stringResult;

def get_cityzip_pairs_id(cityzip_pairs_city, cityzip_pairs_zipcore):
    return "(SELECT cityzip_pairs_id FROM cityzip_pairs WHERE cityzip_pairs_city = '" + cityzip_pairs_city + "' AND cityzip_pairs_zipcore = '" + cityzip_pairs_zipcore + "' LIMIT 1)"

def generate_addresses(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `addresses` (`addresses_line_1`, `addresses_cityzip_pairs_fk`, `addresses_is_defunct`) VALUES ('" + x[0] + "', " + x[1] + ", " + x[2] + ");\n"
    return stringResult

def get_addresses_id(addresses_line_1):
    return "(SELECT addresses_id FROM addresses WHERE addresses_line_1 = '" + addresses_line_1 + "' LIMIT 1)"

def generate_institutions(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `institutions` (`institutions_legal_name`, `institutions_operating_state_fk`, `institutions_alt_name`, `institutions_mailing_fk`, `institutions_web_url`, `institutions_has_undergraduate_programs`, `institutions_has_postgraduate_programs`, `institutions_is_defunct`) VALUES ('" + x[0] + "', " + x[1] + ", '" + x[2] + "', " + x[3] + ", '" + x[4] + "', " + x[5] + ", " + x[6] + ", " + x[7] + ");\n"
    return stringResult

def get_institutions_id(institutions_alt_name):
    return "(SELECT institutions_id FROM institutions WHERE institutions_alt_name = '" + institutions_alt_name + "' LIMIT 1)"

def generate_semesters(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO semesters (`semesters_name`, `semesters_start`, `semesters_finish`, `semesters_institutions_id_fk`) VALUES ('" + x[0] + "', '" + x[1] + "', '" + x[2] + "', " + x[3] + ");\n"
    return stringResult

def get_semesters_id(semesters_name, semesters_institutions_id_fk):
    return "(SELECT semesters_id FROM semesters WHERE semesters_name = '" + semesters_name + "' AND semesters_institutions_id_fk = " + semesters_institutions_id_fk + " LIMIT 1)"

def generate_persons(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO persons (`persons_legal_name`, `persons_nations_id_fk`, `persons_state-issued_id_states_id_fk`, `persons_personal_email`, `persons_mailing_address_fk`, `persons_is_defunct`) VALUES ('" + x[0] + "', " + x[1] + ", " + x[2] + ", '" + x[3] + "', " + x[4] + ", " + x[5] + ");\n"
    return stringResult;

def get_persons_id(persons_legal_name):
    return "(SELECT persons_id FROM persons WHERE persons_legal_name = '" + persons_legal_name + "' LIMIT 1)"

def generate_students(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO students (`students_persons_id_fk`, `students_institutions_id_fk`, `students_is_defunct`) VALUES (" + x[0] + ", " + x[1] + ", " + x[2] + ");\n"
    return stringResult

def get_students_id(persons_legal_name, institutions_alt_name):
    return "(SELECT students_id FROM students WHERE students_persons_id_fk = " + get_persons_id(persons_legal_name) + " AND students_institutions_id_fk = " + get_institutions_id(institutions_alt_name) + " LIMIT 1)"

def generate_instructors(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO instructors (`instructors_persons_id_fk`, `instructors_institutions_id_fk`, `instructors_is_defunct`) VALUES (" + x[0] +", " + x[1] + ", " + x[2] + ");\n"
    return stringResult

def get_instructors_id(persons_legal_name, institutions_alt_name):
    return "(SELECT instructors_id FROM instructors WHERE instructors_persons_id_fk = " + get_persons_id(persons_legal_name) + " AND instructors_institutions_id_fk = " + get_institutions_id(institutions_alt_name) + " LIMIT 1)"

def generate_employees(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO employees (`employees_persons_id_fk`, `employees_institutions_id_fk`, `employees_is_defunct`) VALUES (" + x[0] + ", " + x[1] + ", " + x[2] + ");\n"
    return stringResult

def get_employees_id(persons_legal_name, institutions_alt_name):
    return "(SELECT employees_id FROM employees WHERE employees_persons_id_fk = " + get_persons_id(persons_legal_name) + " AND employees_institutions_id_fk = " + get_institutions_id(institutions_alt_name) + " LIMIT 1)"

def generate_instructor_logins(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `instructor-logins` (`instructor-logins_instructors_id`, `instructor-logins_institutions_id_fk`, `instructor-logins_string`, `instructor-logins_is_defunct`) VALUES (" + x[0] + ", " + x[1] + ", '" + x[2] + "', " + x[3] + ");\n"
    return stringResult

def generate_student_logins(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `student-logins` (`student-logins_students_id_fk`, `student-logins_institutions_id_fk`, `student-logins_string`, `student-logins_is_defunct`) VALUES (" + x[0] + ", " + x[1] + ", '" + x[2] + "', " + x[3] + ");\n"
    return stringResult

def generate_employee_logins(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `employee-logins` (`employee-logins_employees_id_fk`, `employee-logins_institutions_id_fk`, `employee-logins_string`, `employee-logins_is_defunct`) VALUES (" + x[0] + ", " + x[1] + ", '" + x[2] + "', " + x[3] + ");\n"
    return stringResult

def generate_departments(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO departments (`depts_title`, `depts_institutions_id_fk`, `depts_chairperson_instructors_fk`, `depts_is_defunct`) VALUES ('" + x[0] + "', " + x[1] + ", " + x[2] + ", " + x[3] + ");\n"
    return stringResult

def get_departments_id(depts_title, institutions_alt_name):
    return "(SELECT depts_id FROM departments WHERE depts_title = '" + depts_title + "' AND depts_institutions_id_fk = " + get_institutions_id(institutions_alt_name) + " LIMIT 1)"

def generate_courses(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO courses (`courses_title`, `courses_credit_hours`, `courses_depts_id_fk`, `courses_number`, `courses_undergraduates_eligible`, `courses_postgraduates_eligible`, `courses_is_defunct`) VALUES ('" + x[0] + "', " + x[1] + ", " + x[2] + ", '" + x[3] + "', " + x[4] + ", " + x[5] + ", " + x[6] + ");\n"
    return stringResult

def get_courses_id(courses_dept_name, institutions_alt_name, courses_number):
    return "(SELECT courses_id FROM courses WHERE courses_depts_id_fk = " + get_departments_id(courses_dept_name, institutions_alt_name) + " AND courses_number = " + courses_number + " LIMIT 1)"

def generate_courses_prerequisites(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `courses-prerequisites` (`courses_id_fk`, `courses_requires_courses_id_fk`) VALUES (" + x[0] + ", " + x[1] + ");\n"
    return stringResult

def generate_tracks(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO tracks (`tracks_title`, `tracks_institutions_id_fk`, `tracks_is_undergraduate_program`, `tracks_is_postgraduate_program`, `tracks_is_defunct`) VALUES ('" + x[0] +"', " + x[1] + ", " + x[2] + ", " + x[3] + ", " + x[4] + ");\n"
    return stringResult

def get_tracks_id(tracks_title, institutions_alt_name):
    return "(SELECT tracks_id FROM tracks WHERE tracks_title = '" + tracks_title + "' AND tracks_institutions_id_fk = " + get_institutions_id(institutions_alt_name) + " LIMIT 1)"

def generate_tracks_prerequisites(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `tracks-prerequisites` (`tracks-prerequisites_tracks_id_fk`, `tracks-prerequisites_requires_courses_id_fk`) VALUES (" + x[0] + ", " + x[1] + ");\n"
    return stringResult

def generate_course_equivalencies(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `courses-equivalencies` (`courses-equivalencies_a`, `courses-equivalencies_b`) VALUES (" + x[0] + ", " + x[1] + ");\n"
    return stringResult

def generate_locations(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO locations (`locations_title`, `locations_is_defunct`) VALUES ('" + x[0] + "', " + x[1] + ");\n"
    return stringResult

def get_locations_id(locations_title):
    return "(SELECT locations_id FROM locations WHERE locations_title = '" + locations_title + "' LIMIT 1)"

def generate_schedules(t):
    stringResult = ""
    for x in t: # note here the boolean is used for whether the meetings are virtual, not the typical is_defunct flag (which is not available on this table)
        stringResult += "INSERT INTO schedules (`schedules_start_24hr`, `schedules_end_24hr`, `schedules_dow`, `schedules_start`, `schedules_finish`, `schedules_meetings_are_virtual`, `schedules_semesters_id_fk`) VALUES ('" + x[0] + "', '" + x[1] + "', '" + x[2] + "', '" + x[3] + "', '" + x[4] + "', " + x[5] + ", " + x[6] + ");\n"
    return stringResult

def get_schedules_id(schedules_start_24hr, schedules_end_24hr):
    return "(SELECT schedules_id FROM schedules WHERE schedules_start_24hr = '" + schedules_start_24hr + "' AND schedules_end_24hr = '" + schedules_end_24hr + "' LIMIT 1)"

def generate_tasks(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO tasks (`tasks_title`, `tasks_max_points_towards_gpa`, `tasks_points_count_towards_gpa`) VALUES ('" + x[0] + "', " + x[1] + ", " + x[2] + ");\n"
    return stringResult

def get_tasks_id(tasks_title):
    return "(SELECT tasks_id FROM tasks WHERE tasks_title = '" + tasks_title + "' LIMIT 1)"

def generate_courses_tasks(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO `courses-tasks` (`courses-tasks_tasks_id_fk`, `courses-tasks_courses_id_fk`, `courses-tasks_points_coefficient`) VALUES (" + x[0] + ", " + x[1] + ", " + x[2] + ");\n"
    return stringResult

def generate_enrollments(t):
    stringResult = ""
    for x in t: # the tuple will be out of order from the demo, sorry!
        stringResult += "INSERT INTO enrollments (`enrollments_schedules_id_fk`, `enrollments_instructors_id_fk`, `enrollments_students_id_fk`, `enrollments_courses_id_fk`, `enrollments_is_auditing`) VALUES (" + x[2] + ", " + x[1] + ", " + x[0] + ", " + x[3] + ", " + x[4] + ");\n" 
    return stringResult

def get_enrollments_id(persons_legal_name, institutions_alt_name, schedules_start_24hr, schedules_end_24hr):
    return "(SELECT enrollments_id FROM enrollments WHERE enrollments_schedules_id_fk = " + get_schedules_id(schedules_start_24hr, schedules_end_24hr) + " AND enrollments_students_id_fk = " + get_students_id(persons_legal_name, institutions_alt_name) + " LIMIT 1)"

def generate_grades(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO grades (`grades_enrollments_id_fk`, `grades_points_towards_gpa`, `grades_tasks_id_fk`, `grades_date_created`, `grades_date_last_updated`) VALUES (" + x[0] + ", " + x[1] + ", " + x[2] + ", '" + x[3] + "', '" + x[4] + "');\n"
    return stringResult

# this has a primary key because financial tables will foreign key link to this later, this is the bridge between money flowing in/out AND what students/instructors are doing, AND when they are doing it
def generate_services(t):
    stringResult = ""
    for x in t:
        stringResult += "INSERT INTO services (`services_instructors_id_fk`, `services_students_id_fk`, `services_schedules_id_fk`, `services_semesters_id_fk`) VALUES (" + x[0] + ", " + x[1] + ", " + x[2] + ", " + x[3] +");\n"
    return stringResult
