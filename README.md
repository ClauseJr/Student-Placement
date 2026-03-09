# Student Placement End-to-End Analysis

## Executive Summary

### Overview Findings

This project demonstrates end-to-end data analysis of student placement outcomes, integrating academic performance, technical skills, communication ability, and interview readiness into a unified analytical model. Using Power BI and DAX, key placement metrics including placement rate, skill impact, readiness score, and placement risk were calculated to evaluate employability patterns. Cohort segmentation and readiness modeling were applied to identify job-ready students and high-risk groups. The resulting dashboards provide actionable insights into how technical competencies, communication skills, and interview preparation influence overall placement success.

The interactive Power BI dashboard enables us to:
  -  Analyze the impact of academic performance, communication skills, logical reasoning, interviews, projects, students aptitude, number of internships, and technical skills on placement success.
  -  Identify trends in placement rates, placement risks and the number of students placed.
  -  Identifying the risk factors that are likely to contribute in placement readiness of students.
  -  Understand temporal mechanism the contributes to high student placement success.
  -  Develop an interactive dashboard suitable for anlysis of student's placement and risk in placement readiness.

### Data Sources

A synthetically generated student placement dataset created for data analytics and visualization practice, containing upto 100,000 records. The dataset simulates academic performance, technical skills, experience indicators, and placement outcomes to analyze factors influencing student employability.

---

## Tools Used
a. Excel

Excel was used as the initial data preparation tool to:
  -  Clean and standardize column formats (texts, numerical fields)
  -  Handle missing, duplicates and inconsistent values
  -  Validate data integrity before visualization

This step ensured the dataset was well structured and analysis-ready before ingestion into PostgreSQL for analysis.

b. SQL(PostgreSQL)

The data was intergrated into PostgreSQl for SQL analysis and data cleaning
  -  Data Collection, Cleaning and Transformation
  -  Trend Analysis
  -  Explanatory analysis, Descriptive analysis and Predictive preparation

c. Power BI

Within Power BI:
  -  Creation of custom columns and conditional columns for data segmentation and trend analysis.
  -  DAX measures were created for the following KPIs:
      -  Total Students, Total Students Placed, Total Students not Placed
      -  Placement Readiness
      -  Placement Rate
      -  Placement Risk

Slicers were implemented for dynamic analysis by Gender and Voluteer experience.
    
---
## Data Analysis

```sql
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
```

<img width="632" height="370" alt="Overview Page" src="https://github.com/user-attachments/assets/d7eb7584-90ee-400c-8621-6e2d7953fb13" />

<img width="633" height="371" alt="Skill Impact Page" src="https://github.com/user-attachments/assets/c4350904-ee54-4d47-8292-002df9569732" />

<img width="632" height="371" alt="Risk Readiness Page" src="https://github.com/user-attachments/assets/3df4111d-6a8b-4921-bfc4-91e1be505bac" />




