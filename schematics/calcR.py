#!/usr/bin/env python3

#
# ------ R1 ----
#              |
# ------ R2 ----
#              |
# ------ R3 ---------RG----- 0
#              |
#              Measure
#

e12 = [1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, 6.8, 8.2]
e12_t = []
for e in e12:
    e12_t.append(e*100)
    e12_t.append(e*1000)
e12_t.sort()
print(e12_t)


def r_parallel(r1, r2):
    return r1*r2/(r1+r2)


def get_voltages(r1, r2, r3, rg):
    voltages = [0]  # none pressed
    voltages.append(rg/(r1+rg))
    voltages.append(rg/(r2+rg))
    voltages.append(rg/(r3+rg))
    voltages.append(rg/(r_parallel(r1, r2)+rg))
    voltages.append(rg/(r_parallel(r1, r3)+rg))
    voltages.append(rg/(r_parallel(r2, r3)+rg))
    voltages.append(rg/(r_parallel(r_parallel(r1, r2), r3)+rg))
    voltages.sort()
    return voltages


def min_distance(arr):
    arr.sort()
    dists = [b-a for a, b in zip(arr[:-1], arr[1:])]
    return min(dists)


def mix():
    max_dist = 0
    best = [0, 0, 0, 0]
    for r1 in e12_t:
        for r2 in e12_t:
            for r3 in e12_t:
                for rg in e12_t:
                    dist = min_distance(get_voltages(r1, r2, r3, rg))
                    if dist > max_dist:
                        max_dist = dist
                        best = [r1, r2, r3, rg]
                        print("dist={} volt={} r1={} r2={} r3={} rg={}"
                              .format(dist, dist*5000, r1, r2, r3, rg))

    print(get_voltages(*best))

mix()
