# Modification notice

## AudiImage
AudiImage is a fork of [CARFAC](https://github.com/google/carfac) project and
focuses on the MATLAB implementation of CARFAC (Cascade of Asymmetric
Resonators with Fast-Acting Compression) and SAI (Stabilized Auditory Images).


### 2025-08-08 - Michael Kuka (b0sch-mike)

commit 212180b6fd0b3441c173663a852586840f74a81a
- delete: C++ implementation (`../cpp`)
- delete: Python implementation (`../python`)
- delete: Test data (`../test_data`)

commit 3238db4eb7fb9d52682013bd72bd0f42b287db74
- delete: `../matlab/CARFAC_Compare_CPP_Test_Data.m`
- delete: `../matlab/CARFAC_GenerateTestData.m`

commit 1025c5a696017c283542f16d0b1c077f6b68c04f
- add: Helper functions (`../helper`)


### 2025-08-11 - Michael Kuka (b0sch-mike)

commit e670d8acded4ea8884b89d586580ffeb3e6d2d95
- add: Core scripts of AudiImage modification
  (`RunComputationOfSai.m`, `RunProcessingOfSai.m`,
   `ParametersToComputeSai.m`, `ParametersToProcessSai.m`, and `../script`)

commit 4fce715eb0d30be061baf510107728e2ff43c6c3
- add: GUI for analysis of SAI
  (`ShowSai.mlapp`, `ParametersToShowSai.m`and `../script/ShowSaiExportDiagrams.mlapp`)


### 2025-08-12 - Michael Kuka (b0sch-mike)

commit 6074e9cb9bcdc2e6c3397ef03f6175f62ccf79f6
- modify: `../matlab/SAI_RunLayered.m`
- modify: `../matlab/MakeMovieFromPngsAndWav.m`

commit 4c3970f242e7a1ac16d9ab338df585fdbc24c807
- add: Helper function for GUI
  (`../script/RecomputeMoviePitchogramForShowSai.m`)