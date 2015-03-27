#define CONCAT_(x, y) x ## y
#define CONCAT(x, y) CONCAT_(x, y)

#define STEP(x) extern void CONCAT(STEP_PREFIX, __LINE__)
#define GIVEN STEP
#define WHEN STEP
#define THEN STEP

