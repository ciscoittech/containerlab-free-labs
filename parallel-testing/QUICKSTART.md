# Quick Start - OSPF Basics Student Exercises

## 1-Minute Quick Start

```bash
# Deploy the lab
cd ospf-basics
sudo containerlab deploy -t topology.clab.yml
sleep 60

# Run student exercises
cd ../parallel-testing
./student-tests/ospf-basics-exercises.sh
```

## Expected Output

```
=========================================
OSPF Basics - Student Exercise Simulation
=========================================

[INFO] Checking if lab containers are running...
[SUCCESS] All lab containers are running

[INFO] Exercise 1: Verify OSPF Neighbors on r1
[SUCCESS] Exercise 1 PASSED: Found 2 neighbors in Full state

[INFO] Exercise 2: View OSPF Routes on r1
[SUCCESS] Exercise 2 PASSED: All routes found

[INFO] Exercise 3: View OSPF Database on r2
[SUCCESS] Exercise 3 PASSED: Found 3 Router LSAs

[INFO] Exercise 4: Test Connectivity from r1 to r3's loopback
[SUCCESS] Exercise 4 PASSED: Ping successful

[INFO] Exercise 5: Verify OSPF is enabled on r2 eth1
[SUCCESS] Exercise 5 PASSED: OSPF enabled on eth1

=========================================
Results Summary
=========================================
Total Exercises: 5
Passed: 5
Failed: 0

[SUCCESS] All exercises passed!
```

## View JSON Results

```bash
cat results/ospf-basics-student-results.json | jq
```

## Files Created

| File | Purpose |
|------|---------|
| `lib/common.sh` | Shared utility functions |
| `lib/result-collector.sh` | JSON result collection |
| `student-tests/ospf-basics-exercises.sh` | Main exercise script |
| `results/ospf-basics-student-results.json` | Output (generated) |

## Exercise Checklist

- ✅ Exercise 1: Verify OSPF Neighbors (2 neighbors in Full state)
- ✅ Exercise 2: View OSPF Routes (3 routes learned)
- ✅ Exercise 3: View OSPF Database (3 Router LSAs)
- ✅ Exercise 4: Test Connectivity (ping r3 loopback)
- ✅ Exercise 5: Verify OSPF Interface (eth1 in area 0)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Container not running | `cd ospf-basics && sudo containerlab deploy -t topology.clab.yml` |
| Exercises failing | Wait longer for OSPF: `sleep 60` |
| Permission denied | `chmod +x student-tests/ospf-basics-exercises.sh` |

## Documentation

- `README.md` - Framework overview
- `USAGE.md` - Detailed usage guide
- `CREATED.md` - What was built
- `QUICKSTART.md` - This file

## Next Steps

1. Run the script against a deployed lab
2. Check JSON output for detailed results
3. Extend framework for other labs (BGP, VyOS, etc.)
4. Integrate into CI/CD pipeline
