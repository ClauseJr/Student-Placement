---------------------------------------------
-- STUDENT PLACEMENT SQL MAIN QUERY ANALYSIS
---------------------------------------------

SELECT * FROM student_placement_data;

-- 1. Identify the Strongest Academic Driver of Placement
-- Determine which CGPA grade category (Indian grading scale) has the highest placement rate and quantify the difference
	-- between the top-performing and lowest-performing grade segments.



SELECT
	placement_status,
	COUNT(*) no_students
FROM student_placement_data
GROUP BY placement_status
ORDER BY no_students DESC;



SELECT
	CASE
		WHEN cgpa >= 9 THEN 'Outstanding (0)'
		WHEN cgpa >= 8 THEN 'Excellent (A+)'
		WHEN cgpa >= 7 THEN 'Very Good (A)'
		WHEN cgpa >= 6 THEN 'Good (B+)'
		WHEN cgpa >= 5 THEN 'Average (B)'
		ELSE 'Fail'
	END AS cgpa_segmentation,
	
	COUNT(*) total_number_students,
	ROUND(
		COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) * 100.0 
	/ COUNT(*),2) placement_rate
FROM student_placement_data
GROUP BY cgpa_segmentation
ORDER BY placement_rate DESC
-- Placement is determined by performance, higher cgpa score aggregates to one being placed and vice versa is true


-- 2. Technical Skill vs Placement Efficiency
-- Compare placement rates across coding skill segments and determine whether “Advanced” coders are statistically 
	-- more likely to be placed than “Intermediate” coders.

SELECT
	CASE
		WHEN coding_skill_score >= 85 THEN 'Advanced'
		WHEN coding_skill_score >= 70 THEN 'Proficient'
		WHEN coding_skill_score >= 50 THEN 'Intermediate'
		ELSE 'Beginner'
	END AS coding_skills_seg,
	COUNT(*) total_number_students,
	ROUND(
		COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) * 100.0 
	/ COUNT(*),2) placement_rate
FROM student_placement_data
GROUP BY coding_skills_seg
ORDER BY placement_rate DESC

-- Based on the Placement Rates:
	-- Advanced coders are more likely to be placed compared to the intermediate coders due to difference in technical coding skills


-- 3. Internship Experience Threshold Analysis
-- Identify the minimum number of internships required after which placement probability significantly increases.


SELECT
	internships_count,
	COUNT(*) total_number_students,
	ROUND(
		COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) * 100.0 
		/ COUNT(*),2) placement_rate
FROM student_placement_data
GROUP BY internships_count
ORDER BY placement_rate

-- More internships → stronger employability → higher placement probability.
-- Placebility starts at a Threshold of 3 internships (2 - 3 internship diff 5%)


-- 4. Soft Skills vs Technical Skills Impact
-- Compare placement rates between: 
	-- Students with high technical skills but weak communication
	-- Students with moderate technical skills but strong communication
	
WITH student_tech_soft_score AS (
	SELECT
		*,
		ROUND(
			(coding_skill_score 
			+ aptitude_score 
			+ logical_reasoning_score 
			+ mock_interview_score)::numeric / 4.0
		,2) AS TechSkills_Score
	FROM student_placement_data
)
SELECT 
	CASE
		WHEN TechSkills_Score >= 75 AND communication_skill_score < 60 THEN 'HighTech_WeakComm'
		WHEN TechSkills_Score >= 55 AND TechSkills_Score < 75 AND communication_skill_score >= 75 THEN 'ModerateTech_StrongComm'
	END AS student_cohort,
	
	COUNT(*) total_number_students,
	ROUND(
		COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) * 100.0 / COUNT(*)
	,2) placement_rate
FROM student_tech_soft_score
WHERE (TechSkills_Score >= 75 AND communication_skill_score < 60) OR
	(TechSkills_Score >= 55 AND TechSkills_Score < 75 AND communication_skill_score >= 75)
GROUP BY student_cohort
ORDER BY placement_rate DESC


-- Students with very high technical skills but weak communication have slightly higher placement success 
	-- than students with moderate technical skills but strong communication, though the difference is marginal.




-- 5. Multi-Factor Performance Profiling
-- Find the top 5 combinations of: Coding segment, Communication segment and Internship segment, that produce the highest placement rate.

SELECT 
	coding_skills_seg,
	communication_seg,
	internship_seg,
	total_number_students,
	placement_rate,
	stud_placement_rank_score
FROM (
	
	WITH student_segmentations_score AS(
		SELECT
			*,
			CASE
				WHEN coding_skill_score >= 85 THEN 'Advanced'
				WHEN coding_skill_score >= 70 THEN 'Proficient'
				WHEN coding_skill_score >= 50 THEN 'Intermediate'
				ELSE 'Beginner'
			END AS coding_skills_seg,	
	
			CASE
			    WHEN communication_skill_score >= 85 THEN 'Excellent'
			    WHEN communication_skill_score >= 70 THEN 'Good'
			    WHEN communication_skill_score >= 50 THEN 'Average'
		    	ELSE 'Poor'
			END AS communication_seg,
	
			CASE
			    WHEN internships_count >= 3 THEN 'Highly Experienced'
			    WHEN internships_count = 2 THEN 'Experienced'
			    WHEN internships_count = 1 THEN 'Basic Exposure'
			    ELSE 'No Experience'
			END AS internship_seg
		FROM student_placement_data
	),
	rank_placement_score AS(
		SELECT 
			coding_skills_seg,
			communication_seg,
			internship_seg,
			COUNT(*) total_number_students,
			ROUND(
				COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) * 100.0 / COUNT(*)
			,2) placement_rate
		FROM student_segmentations_score
		GROUP BY 
			coding_skills_seg,
			communication_seg,
			internship_seg
	)
	SELECT
		coding_skills_seg,
		communication_seg,
		internship_seg,
		total_number_students,
		placement_rate,
		RANK() OVER(ORDER BY placement_rate DESC) stud_placement_rank_score
	FROM rank_placement_score
)
WHERE stud_placement_rank_score <= 10


-- 6. Certification ROI Analysis
-- Evaluate whether students with 3 or more certifications have significantly higher placement rates than those with fewer than 3.


SELECT
 	CASE 
		WHEN certifications_count >= 3 THEN '3+ Certifications'
		ELSE '<3 Certifications'
	END cert_seg,
	COUNT(*) total_number_students,
	ROUND(
		COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) * 100.0 
		/ COUNT(*),2) placement_rate
FROM student_placement_data
GROUP BY cert_seg
ORDER BY placement_rate DESC

-- Placement 3+ = 41.54%
-- Placement <3 = 39.26%
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

WITH cert_segementation AS (
    SELECT
        CASE 
			WHEN certifications_count >= 3 THEN '3+ Certifications'
			ELSE '<3 Certifications'
		END AS certificate_seg,
        COUNT(*) AS n,
        COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) AS student_placed
    FROM student_placement_data
    GROUP BY certificate_seg
),
pivoted AS (
    SELECT
        MAX(CASE WHEN certificate_seg = '3+ Certifications' THEN n END) AS n1,
        MAX(CASE WHEN certificate_seg = '3+ Certifications' THEN student_placed END) AS x1,
        MAX(CASE WHEN certificate_seg = '<3 Certifications' THEN n END) AS n2,
        MAX(CASE WHEN certificate_seg = '<3 Certifications' THEN student_placed END) AS x2
    FROM cert_segementation
),
calculations AS (
    SELECT
        n1, x1, n2, x2,
        x1::float / n1 AS p1,
        x2::float / n2 AS p2
    FROM pivoted
)
SELECT
    n1 AS Certifications_more_three_total,
    n2 AS Certifications_less_three_total,
    
    ROUND(p1::numeric,4) AS placement_rate_more_three,
    ROUND(p2::numeric,4) AS placement_rate_less_three,
    
    ROUND((p1 - p2)::numeric,4) AS difference_in_placement_rates,
    
    -- Standard Error
    SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS standard_error,
    
    -- Margin of Error (95%)
    1.96 * SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS margin_of_error,
    
    -- Confidence Interval Lower Bound
    (p1 - p2) - 1.96 * SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS ci_lower,
    
    -- Confidence Interval Upper Bound
    (p1 - p2) + 1.96 * SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS ci_upper

FROM calculations;

-- Placement 3+ = 41.54%
-- Placement <3 = 39.26%
-- 95% Confidence Interval (0.0163 , 0.0293)
-- Difference in placement = 2.28%




-- 7. Project Intensity Influence
-- Analyze whether project-intensive students (≥5 projects) outperform those with fewer projects in placement outcomes.




WITH project_segementation AS (
    SELECT
        CASE 
            WHEN projects_count >= 5 THEN 'Project-Intensive'
            ELSE 'Less Intensive'
        END AS project_seg,
        COUNT(*) AS n,
        COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) AS stud_placed
    FROM student_placement_data
    GROUP BY project_seg
),
pivoted AS (
    SELECT
        MAX(CASE WHEN project_seg = 'Project-Intensive' THEN n END) AS n1,
        MAX(CASE WHEN project_seg = 'Project-Intensive' THEN stud_placed END) AS x1,
        MAX(CASE WHEN project_seg = 'Less Intensive' THEN n END) AS n2,
        MAX(CASE WHEN project_seg = 'Less Intensive' THEN stud_placed END) AS x2
    FROM project_segementation
),
calculations AS (
    SELECT
        n1, x1, n2, x2,
        x1::float / n1 AS p1,
        x2::float / n2 AS p2
    FROM pivoted
)

SELECT
    n1 AS high_intensive_total,
    n2 AS less_intensive_total,
    
    ROUND(p1::numeric,4) AS placement_rate_high_intensive,
    ROUND(p2::numeric,4) AS placement_rate_less_intensive,
    
    ROUND((p1 - p2)::numeric,4) AS difference_in_placement_rates,
    
    -- Standard Error
    SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS standard_error,
    
    -- Margin of Error (95%)
    1.96 * SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS margin_of_error,
    
    -- Confidence Interval Lower Bound
    (p1 - p2) - 1.96 * SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS ci_lower,
    
    -- Confidence Interval Upper Bound
    (p1 - p2) + 1.96 * SQRT(
        (p1 * (1 - p1) / n1) +
        (p2 * (1 - p2) / n2)
    ) AS ci_upper

FROM calculations;


-- Placement 5> = 43.50%
-- Placement <5 = 39.22%
-- 95% Confidence Interval (0.0348 , 0.0507)
-- Difference in placement = 4.28%

-- Students with five or more academic projects exhibit a statistically significant placement advantage of 4.28% points compared to students with fewer projects (95% Confidence Interval: 3.48%–5.07%).



-- 8. High CGPA but Not Placed – Risk Identification
-- Identify students with CGPA ≥ 8.5 who were not placed and analyze their technical and soft skill weaknesses.

SELECT
	CASE
		WHEN cgpa >= 8.5 THEN 'CGPA 8.5+'
		ELSE 'CGPA <8.5'
	END AS cgpa_segmentation,
	
	COUNT(*) total_number_students
FROM student_placement_data
WHERE placement_status = 'Not Placed'
GROUP BY cgpa_segmentation;

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------


WITH student_tech_soft_score AS (
	SELECT
		*,
		ROUND(
			(coding_skill_score 
			+ aptitude_score 
			+ logical_reasoning_score 
			+ mock_interview_score)::numeric / 4.0
		,2) AS TechSkills_Score
	FROM student_placement_data
)
SELECT
	CASE
		WHEN TechSkills_Score < 60 AND communication_skill_score < 60 THEN 'Weak_tech_comm_skills'
		WHEN TechSkills_Score < 60 THEN 'Weak_tech_skills'
		WHEN communication_skill_score < 60 THEN 'Weak_comm_skills'
		ELSE 'Balanced'
	END skills_segmentation,
	COUNT(*) total_number_students,
	ROUND(AVG(TechSkills_Score)::numeric,2) avg_tech_skills_Score,
	ROUND(AVG(communication_skill_score)::numeric,2) avg_comm_skill_score
	
FROM student_tech_soft_score
WHERE cgpa >= 8.5 AND placement_status = 'Not Placed'
GROUP BY skills_segmentation
ORDER BY total_number_students DESC;

-- Total high-CGPA but not placed = 14,904 students
	-- a. Weak_tech_comm_skills (69% of group)
		-- Tech avg = 42.12
		-- Comm avg = 30.00
	-- b. Weak_tech_skills (28%)
		-- Tech avg = 37.54 (very low)
		-- Comm avg = 78.46 (strong)
	-- c. Weak_comm_skills (2.6%)
		-- Tech avg = 62.75
		-- Comm avg = 16.51
	-- d. Balanced (4 students)
		-- Tech = 61.85
		-- Comm = 76.23



-- 9. Build a SQL-Based Placement Readiness Ranking
--- Create a composite ranking score using: CGPA, Coding score, Aptitude, Internship count, Mock interview score. Then rank the top 100 most placement-ready students.

WITH stud_placement_scores AS(

	SELECT
		*,
		(cgpa * 10) AS max_cgpa_scale, -- cgpa scale 10
		(internships_count::numeric /7) * 100 AS max_internship_scale, 
		
		(0.25 * (cgpa * 10) +
			0.25 * coding_skill_score +
			0.15 * aptitude_score +
			0.15 * mock_interview_score +
			0.20 * ((internships_count::numeric / 7) * 100)
		) AS placement_readiness_score
	
	FROM student_placement_data
),
stud_composite_ranking AS(
	SELECT
		student_id,
		age,
		gender,
		CASE
			WHEN cgpa >= 9 THEN 'Outstanding (0)'
			WHEN cgpa >= 8 THEN 'Excellent (A+)'
			WHEN cgpa >= 7 THEN 'Very Good (A)'
			WHEN cgpa >= 6 THEN 'Good (B+)'
			WHEN cgpa >= 5 THEN 'Average (B)'
			ELSE 'Fail'
		END AS cgpa_seg,
	
		CASE
		    WHEN coding_skill_score >= 85 THEN 'Advanced'
		    WHEN coding_skill_score >= 70 THEN 'Proficient'
		    WHEN coding_skill_score >= 50 THEN 'Intermediate'
		    ELSE 'Beginner'
		END AS coding_seg,
		
		CASE
		    WHEN aptitude_score >= 80 THEN 'High Aptitude'
		    WHEN aptitude_score >= 65 THEN 'Moderate'
		    WHEN aptitude_score >= 50 THEN 'Low'
		    ELSE 'Very Low'
		END AS aptitude_seg,
		
		CASE
		    WHEN mock_interview_score >= 85 THEN 'Interview Ready'
		    WHEN mock_interview_score >= 70 THEN 'Good Potential'
		    WHEN mock_interview_score >= 50 THEN 'Needs Improvement'
		    ELSE 'Not Ready'
		END AS interview_seg,
		
		CASE
		    WHEN internships_count >= 3 THEN 'Highly Experienced'
		    WHEN internships_count = 2 THEN 'Experienced'
		    WHEN internships_count = 1 THEN 'Basic Exposure'
		    ELSE 'No Experience'
		END AS internship_seg,
	
		ROUND(placement_readiness_score::numeric, 2) readiness_score,
		RANK() OVER(ORDER BY placement_readiness_score DESC) rank_stud_placement_score
	FROM stud_placement_scores
	ORDER BY readiness_score DESC
)
SELECT
	student_id,
	age,
	gender,
	cgpa_seg,
	coding_seg,
	aptitude_seg,
	interview_seg,
	internship_seg,
	readiness_score,
	rank_stud_placement_score
FROM stud_composite_ranking
WHERE rank_stud_placement_score <= 100











