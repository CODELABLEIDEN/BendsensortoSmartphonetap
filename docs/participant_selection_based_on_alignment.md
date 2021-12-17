# Participant selection based on 'successful' alignment
Plots can be found at: 
path = '/media/Storage/Common_Data_Storage/test_ruchella/aligned_model_plots'

**Total files:** 211 with both BS and tap data 

**Total files after decision tree:** 177 (This is also number of plots)

## No
The folder no contains participants where the alignment has been visually identified as substandard. The following reasons are given for this placement. Some participants who belong to those reasons are given underneath. Although often it is not mutually exclusive.

Total: 30 

Percentage: 14.2%

1. Multiple large peaks of model predictions where the differences between the max values are not very big. 
    - MD04_4, MD13_4,  ME04_6, AT10_2, NG06_6, DS97_2, DS12_2
2. Lowest point of the BS signal is very far from the tap
    - AG02_2, AT04_8, AT10_2, TT08_6, TT08_4
3. BS signal looks very atypical (has many highs and lows) *and* the model signals also look atypical (atypical for the model is many large predictions and a lot of noise in the signal or no clear peak)
    - DB03_8, KE11_8, KN01_6, TT10_4, TT02_10, RW33_2, Rw36_2, RW31_2, JB12_8, JB10_10, MD07_4, KN05_4, DS29_2, DS16_2, NG02_4
4. BS signal might be flipped
    - DB06_8, ME99_2, ME99_6, DB07_4, TT11_4


## Maybe 
The folder maybe contains participants where it is unclear whether the alignment was successful. 

Total: 21

Percentage: 11.9%
1. No clear peak in model prediction but clear BS signal / unclear where top of model pred is
    - NG10_6, DS10_2, DB03_6, AG06_2, NG10_6, KN07_6, MD99_8, NG02_8, TT06_4, TT01_4, TT12_4, TT12_6, KE10_4, KN01_4, 
2.  No clear BS signal but clear peak in model prediction 
    - NG11_4, ME09_4, MD13_2, JB12_6, DS99_6, NG11_4, NG01_4, RW39_2

## Probably:
The folder maybe contains participants where it is not entirely clear, but likely, that the alignment was successful. 

Total: 18

Percentage: 10.2%
1. The BS signal looks like a dampening sine wave but the lowest point of the BS and highest point of the model is around the tap. 
    - All participants in folder

## Yes:
The folder yes contains participants where the alignment was successful. 

Total: 108

Percentage: 61.0%
1. Clear BS signal and model signal. Both the lowest point of the BS and highest point of the model is around the tap. 
note: Most of the time the model prediction is highest slightly before the tap occurs.
------------------------------------------------------------------------------------------------------------------------
# Distribution of model predictions around tap
![distribution model and bs data around_tap](../reports/figures/distribution.jpg)

Position of max value of model prediction is ***3*** std away from tap

Total: 3 
- Before tap: TT02_10
- After tap: KE10_4, MD99_8

Position of min value of BS data ***3*** std away from tap

Total: 7 
- Before: AG02_2, TT08_4, TT08_6 
- After: DB03_8, DS12_2, DS29_2, ME04_6
------------------------------------------------------

Position of max value of model prediction ***2*** std away from tap

Total: 4 
- Before: TT02_10, ED05_6
- After: KE10_4, MD99_8

Position of min value of BS data ***2*** std away from tap

Total: 8 
- Before: AG02_2, TT08_4, TT08_6 
- After: DB03_8, DS12_2, DS29_2, ME04_6, AT04_8
------------------------------------------------------

Position of max value of model prediction ***1*** std away from tap

Total: 5
- Before: TT02_10, ED05_6
- After: KE10_4, MD99_8, MD03_6

Position of min value of BS data ***1*** std away from tap

Total: 12
- Before: AG02_2, TT08_4, TT08_6, JB12_8, NG01_4
- After: DB03_8, DS12_2, DS29_2, ME04_6, AT04_8, AT10_2, DB06_8

![all epoched model predictions](../reports/figures/all_mean_epoched_model.jpg)
------------------------------------------------------------------------------------------------------------------------
# Both visual and distribution analysis together
Total files in ***No***: 30

Total coinciding with ***No***: 12
- TT02_10, AG02_2, TT08_4, TT08_6, JB12_8, DB03_8, DS12_2, DS29_2, ME04_6, AT04_8, AT10_2, DB06_8

Total in ***Maybe***: 21

Total coinciding with ***Maybe***: 1
- NG01_4, KE10_4, MD99_8

Total in ***Probably***: 17

Total coinciding with ***Probably***: 2
- ED05_6,MD03_6

Total in ***Yes***: 108

Total coinciding with ***Yes***: 0

Note that all participants excluded because 'Lowest point of the BS signal is very far from the tap', were also identified as having the lowest point atleast 1 std away from the tap. 
- AG02_2, AT04_8, AT10_2, TT08_6, TT08_4


----------------------------------------------------
# Peak prominance
### Difference between largest peak and mean peaks with threshold 0.10

Max(prominance) -  mean(prominance) <0.10

Total: 7 

- RW41_2, RW31_2, NG06_6, MD99_8, KN07_8, DS10_2, AG02_2

Total in ***no***: 30

Coinciding with  ***no***: 2

- AG02_2, RW31_2

Total in  ***maybe***: 21

Coinciding with ***maybe***: 3

- MD99_8, KN07_8, DS10_2 

Total in  ***probably***: 17

Coinciding with  ***probably***: 3

- RW41_2, NG06_6 
------------------------------------------------
### Difference between largest peak and mean peaks with threshold 0.15
Max(prominance) -  mean(prominance) < 0.15

Total: 24

Total in ***no***: 30

Coinciding with  ***no***: 11

Percentage: 36.7% 

- AG02_2, DB07_4, DS16_2, JB10_10, JB12_8, KE11_8, KN05_4, MD07_4, MD13_4, RW31_2, TT10_4

Total in  ***maybe***: 21

Coinciding with  ***maybe***: 5

Percentage: 23.8% 

- DS10_2, DS99_6, KB07_8, MD99_8, TT06_4

Total in  ***probably***: 17

Coinciding with  ***probably***: 6

Percentage: 35.3% 

- JB10_4, ME99_6, NG06_6, RW41_2, TT01_6, KN05_6

Total in  ***yes***: 108

Coinciding with  ***yes***: 4

Percentage: 3.7%

DS04_2, DS33_2, JB02_10, TT99_6

---------------------------------
### Difference between two largest peaks
max(prominance) -  max2(prominance) < 0.15

Total: 48

- AG02_2, AG03_8, AG06_2, AT04_4, AT10_2, DB03_6, DB07_2, DB07_4, DS04_2, DS10_2, DS12_2, DS16_2, DS27_2, DS29_2, DS33_3, DS97_2, DS99_6, JB02_10, JB07_4, JB10_4, JB10_10, JB11_10, JB12_6, JB12_8, KE11_8, KN05_4, KN05_6, KN07_8, MD07_4, MD13_2, MD13_4, MD99_8, ME04_6, ME99_6, NG06_4, NG06_6, RW20_2, RW31_2, RW33_2, RW36_2, RW39_2, RW41_2, RW42_2, TT01_6, TT06_4, TT08_4,  TT10_4, TT99_6

Total in ***no***: 30

Coinciding with  ***no***: 20

Coinciding with distribution: 7 

Percentage: 66.7 %

- AG02_2, AT10_2, DB07_4, DS12_2, DS16_2, DS29_2, DS97_2, JB10_10, JB12_8, KE11_8, KN05_4, MD07_4, MD13_4, ME04_6, ME99_6, RW31_2, RW33_2, RW36_2, TT08_4, TT10_4

Distribution and max-max2<0.15 and no: 25

Percentage 83.3%

- TT02_10, TT08_6, DB03_8, AT04_8, DB06_8, AG02_2, AT10_2, DB07_4, DS12_2, DS16_2, DS29_2, DS97_2, JB10_10, JB12_8, KE11_8, KN05_4, MD07_4, MD13_4, ME04_6, ME99_6, RW31_2, RW33_2, RW36_2, TT08_4, TT10_4


Total in  ***maybe***: 21

Coinciding with ***maybe***: 11

Coinciding with distribution: 1

Percentage: 52.4 %

- AG06_2, DB03_6, DS10_2, DS99_6, JB12_8, KN07_8, MD13_2, MD99_8, NG06_4, RW39_2, TT06_4, 

Distribution and max-max2<0.15 and maybe: 13

Percentage: 61.9%

- NG01_4, KE10_4, AG06_2, DB03_6, DS10_2, DS99_6, JB12_8, KN07_8, MD13_2, MD99_8, NG06_4, RW39_2, TT06_4, 

Total in ***probably***: 17

Coinciding with ***probably***: 8

Coinciding with distribution: 0

Percentage: 47.1 % 

- DS27_2, JB07_4, JB10_4, KN05_6, NG06_6, RW20_2, RW41_2, TT01_6, 

Distribution and max-max2<0.15 and probably: 10

Percentage: 58.8 %

- ED05_6,MD03_6, DS27_2, JB07_4, JB10_4, KN05_6, NG06_6, RW20_2, RW41_2, TT01_6, 

Total in ***yes***: 108

Coinciding with ***yes***: 9 

Percentage: 8.3%

- AG03_8, AT04_4, DB07_2, DS04_2, DS33_3, JB02_10, JB11_10, RW42_2, TT99_6
--------------------------------
max(minmaxnorm()) -  max2(minmaxnorm()) < 0.25

Total: 21

- AG02_2, AG03_8, AG06_2, AT10_2, DB03_6, DB07_4, DS12_2, DS16_2, DS27_2, DS19_2, DS33_2, DS97_2, JB07_4, JB10_4, KE11_8, KN07_8, MD99_8, ME04_6, TT08_4, TT08_6, TT99_6

Total in ***no***: 30

Coinciding with ***no***: 10

Percentage: 33.3%

- AG02_2, AT10_2, DB07_4,  DS12_2, DS16_2, DS97_2, KE11_8, ME04_6,  TT08_4, TT08_6,

Total in  ***maybe***: 21

Coinciding with ***maybe***: 4

Percentage: 19 %

- AG06_2, DB03_6, KN07_8, MD99_8, 

Total in ***probably***: 17

Coinciding with ***probably***: 3

Percentage:  17 % 

- DS27_2, JB07_4, JB10_4 

Total in ***yes***: 108

Coinciding with ***yes***: 4

Percentage: 3.7 % 

- AG03_8, DS19_2, DS33_2, TT99_6
