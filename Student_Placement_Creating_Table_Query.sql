

DROP TABLE IF EXISTS student_placement_data;

CREATE TABLE student_placement_data(
	student_id BIGINT,
	age	INT,
	gender VARCHAR(25),
	cgpa FLOAT,
	branch VARCHAR(30),
	college_tier VARCHAR(10),
	attendance_percentage FLOAT,	
	backlogs INT,
	study_hours_per_day	FLOAT,
	coding_skill_score FLOAT,
	aptitude_score FLOAT,
	logical_reasoning_score	FLOAT,
	certifications_count INT,
	projects_count INT,
	github_repos INT,	
	internships_count INT,
	communication_skill_score FLOAT,
	mock_interview_score FLOAT,
	linkedin_connections INT,
	extracurricular_score FLOAT,	
	leadership_score FLOAT,
	volunteer_experience VARCHAR(10),
	sleep_hours	FLOAT,
	placement_status VARCHAR(25)

)

SELECT * FROM student_placement_data;

SELECT 
	COUNT(*)
FROM student_placement_data;

SELECT
	student_id,
	COUNT(*) no_students
FROM student_placement_data
GROUP BY student_id
	HAVING COUNT(*) > 1

SELECT *
FROM student_placement_data
WHERE student_id IS NOT NULL

SELECT
	volunteer_experience,
	COUNT(*) students_per_age
FROM student_placement_data
GROUP BY volunteer_experience
ORDER BY students_per_age DESC