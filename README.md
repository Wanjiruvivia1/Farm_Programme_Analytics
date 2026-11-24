# Farm_Programme_Analytics
SQL and Power BI analysis of a synthetic smallholder farm programme
# Farm Programme Performance Analytics

SQL and Power BI analysis of a **synthetic** smallholder agriculture programme dataset (not real company data).

## Business question
How effectively is the programme recruiting, training, retaining and supporting farmers?

## Workflow
1. `sql/01_create_staging_tables.sql`: staging tables
2. `sql/02_profiling.sql`: data-quality checks
3. `sql/03_cleaning.sql`: clean tables
4. `sql/04_analysis.sql`: KPIs and views
5. `docs/kpi_definitions.md`: how each KPI is defined

## Data quality findings
- 3 exact duplicate records (farmers, sales, attendance)
- Mixed county spellings and a non-standard status values
- 1 sales total that does not match quantity x price

## Status
Power BI dashboard: in progress
