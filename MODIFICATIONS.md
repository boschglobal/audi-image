# Modification notice

## AudiImage
AudiImage is a fork of [CARFAC](https://github.com/google/carfac) project and
focuses on the MATLAB implementation of CARFAC (Cascade of Asymmetric
Resonators with Fast-Acting Compression) and SAI (Stabilized Auditory Images).

### 2025-08-08 - Michael Kuka (b0sch-mike)
commit 212180b6fd0b3441c173663a852586840f74a81a
- deleted: C++ implementation (`../cpp/`)
- deleted: Python implementation (`../python/`)
- deleted: Test data (`../test_data`)

commit 3238db4eb7fb9d52682013bd72bd0f42b287db74
- deleted: `../matlab/CARFAC_Compare_CPP_Test_Data.m`
- deleted: `../matlab/CARFAC_GenerateTestData.m`



**TODO** provide own test files for hacking scripts as `../test_data` is deleted
- `../matlab/CARFAC_binaural.m`
- `../matlab/CARFAC_hacking.m`
- `../matlab/CARFAC_SAI_hacking.m`