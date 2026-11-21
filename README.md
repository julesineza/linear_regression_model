Mission and Problem

**Mission:** Improve food security across Sub-Saharan Africa by using my software engineering skills to build prediction tools that help agricultural decision makers plan better.
**Problem:** Sub-Saharan Africa faces high food insecurity and a scarcity of reliable agricultural data, so planners often lack a quick estimate of how productive a crop will be before the season.
**Solution:** This project predicts crop yield (tonnes per hectare) from the country, crop, season, production system, planted area and planting/harvest timing, and serves it through an API and a mobile app for extension officers and food-security planners.

Dataset 

**HarvestStat Africa** is an open-access collection of harmonized subnational crop statistics for Sub-Saharan Africa. It is built from agricultural statistics collected by USAID's Famine Early Warning Systems Network (FEWS NET), which were standardized and calibrated across changing administrative boundaries. The paper describes 574,204 records, mainly from 1980 to 2022, covering 33 countries and 94 crop types, with quantity produced, harvested area and yield.

The file I used (`hvstat_africa_data_v1_2.csv`) has 217,487 rows and 16 columns: country, regions (`admin_1`, `admin_2`), crop product, season, planting and harvest dates, production system, area (ha), production (t), yield (t/ha) and a quality-control flag. I predict **yield**, and after cleaning I kept 198,872 rows and 8 input features (4 categorical and 4 numeric). Some countries where dropped due to no Yield data as they had no data collected these include : Country	Share of yield missing
Guinea	100%
Sierra Leone	91%
Burundi	78%
DRC		67%
so prediction for this countries might not be accurate or not possible using this dataset 

- Paper: https://www.nature.com/articles/s41597-025-05001-z
- Data: https://datadryad.org/dataset/doi:10.5061/dryad.vq83bk42w
- Direct link to data with automatic download - https://datadryad.org/downloads/file_stream/4864223


Swagger UI 

https://linear-regression-model-w79d.onrender.com/docs
 
Video Demo 

https://youtu.be/tYfdmQTcb1E


