# Data Quality Audit Report

## Executive Summary

The Tembo Hotel dataset contains 286 booking records with significant data quality issues across multiple dimensions. This audit identifies problems and establishes cleaning priorities for the ETL pipeline.

## Dataset Overview

- **Total Records**: 286
- **Date Range**: January 2024 - December 2024
- **Key Entities**: Guests, Staff, Rooms, Bookings, Services

## Data Quality Issues Identified

### 1. Guest Name Issues
**Severity**: High
**Affected Records**: ~30-40
**Issues Found**:
- Inconsistent casing: `ALICE MWANGI` vs `alice mwangi`
- Leading/trailing whitespace: `  Carol Wanjiku  `
- Mixed title case requirements

**Impact**: Affects guest identification and reporting accuracy

### 2. Phone Number Inconsistencies
**Severity**: Medium
**Affected Records**: 14 missing + 14 malformed
**Issues Found**:
- Multiple formats: `0712345678`, `+254712345678`, `0712-345-678`
- Missing values stored as empty strings
- Inconsistent country code handling

**Impact**: Communication and guest contact management

### 3. Date Format Problems
**Severity**: Critical
**Affected Records**: ~40-50
**Formats Identified**:
- `DD/MM/YYYY`: `05/01/2024`
- `MM-DD-YYYY`: `01-05-2024`
- `DD-MM-YY`: `05-01-24` (2-digit year)
- Standard ISO: `2024-01-05`

**Impact**: Date calculations, reporting, and analytics

### 4. Categorical Data Inconsistencies
**Severity**: High

#### Room Types
- Dirty values: `standard`, `Std`, `DLX`, `STE`
- Clean values: `Standard`, `Deluxe`, `Suite`, `Penthouse`

#### Payment Methods
- Dirty values: `mpesa`, `CASH`, `card`, `bank transfer`
- Clean values: `M-Pesa`, `Cash`, `Card`, `Bank Transfer`

#### Booking Status
- Dirty values: `checked out`, `CANCELLED`
- Clean values: `Checked Out`, `Cancelled`, `No Show`

### 5. Numeric Data Issues
**Severity**: Medium-High

#### Missing Values
- `guest_phone`: 14 missing
- `guest_city`: 14 missing
- `total_amount`: 1 missing
- `guest_rating`: 1 missing
- `service_used/price`: 189 missing (sparse data)

#### Formatting Issues
- `staff_salary`: Contains `KES` prefix
- `total_amount`: May contain commas or currency symbols

### 6. Rating Scale Violations
**Severity**: Low
**Affected Records**: ~10
**Issues**: Values outside 1-5 range or invalid formats

### 7. Duplicate Records
**Severity**: High
**Affected Records**: 1 exact duplicate (`BK0006`)
**Impact**: Inflated metrics and reporting errors

### 8. Logical Inconsistencies
**Severity**: Critical
**Issues**:
- Negative night stays
- Checkout dates before check-in dates
- Impossible date combinations

## Data Cleaning Strategy

### Phase 1: Standardization
1. **Text Normalization**
   - Trim whitespace from all text fields
   - Apply consistent casing (INITCAP for names, Title Case for categories)

2. **Phone Number Standardization**
   - Remove all non-numeric characters
   - Convert +254 prefix to 0 prefix
   - Set empty values to NULL

3. **Date Standardization**
   - Detect format patterns using regex
   - Apply appropriate PostgreSQL date parsing
   - Validate date ranges and logical consistency

### Phase 2: Categorization
1. **Room Types**: Map abbreviations to standard names
2. **Payment Methods**: Standardize to title case
3. **Booking Status**: Apply consistent capitalization

### Phase 3: Validation & Deduplication
1. **Range Validation**: Ensure ratings 1-5, positive night counts
2. **Date Validation**: Check-in before check-out
3. **Duplicate Removal**: Remove exact duplicates by booking_id

### Phase 4: Data Type Conversion
1. **Numeric Casting**: Safe conversion with NULL handling
2. **Date Casting**: ISO format standardization
3. **Boolean Logic**: Proper NULL vs empty string handling

## Expected Outcomes

### Post-Cleaning Metrics
- **Valid Records**: 270-278 (95-97% retention)
- **Standardized Categories**: 100% consistency
- **Valid Dates**: 100% ISO format compliance
- **Clean Names**: 100% proper casing and trimming
- **Valid Ratings**: 100% within 1-5 range

### Data Quality Improvements
- **Completeness**: >95% for critical fields
- **Consistency**: 100% for categorical data
- **Accuracy**: 100% for date and numeric calculations
- **Validity**: 100% for business rules

## Implementation Approach

### Stored Procedure Design
```sql
CREATE PROCEDURE clean_booking_data()
AS $$
-- Comprehensive cleaning logic
-- Modular approach for maintainability
-- Error handling and logging
$$;
```

### Testing Strategy
1. **Unit Tests**: Individual cleaning functions
2. **Integration Tests**: End-to-end pipeline
3. **Data Validation**: Statistical profiling before/after
4. **Business Rules**: Domain-specific validations

### Monitoring & Maintenance
1. **Audit Logging**: Track cleaning operations
2. **Error Reporting**: Failed records handling
3. **Performance Monitoring**: Cleaning duration tracking
4. **Data Quality Metrics**: Ongoing assessment

## Risk Assessment

### High Risk
- Date parsing failures could lose historical data
- Over-aggressive deduplication could remove valid records
- Type casting errors could corrupt numeric data

### Mitigation Strategies
- Backup all data before cleaning
- Implement soft deletes for removed records
- Comprehensive logging of all transformations
- Rollback procedures for critical failures

## Success Criteria

1. **Data Completeness**: >95% valid records retained
2. **Format Consistency**: 100% standardized formats
3. **Business Logic**: All records pass validation rules
4. **Performance**: Cleaning completes within 5 minutes
5. **Maintainability**: Code is well-documented and modular

## Next Steps

1. Implement cleaning stored procedures
2. Develop comprehensive test suite
3. Create monitoring and alerting
4. Document all transformations
5. Establish data quality KPIs