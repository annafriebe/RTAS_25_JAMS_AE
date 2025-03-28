import csv

def parse(filename):
    n_durations = 0
    times = []
    with open(filename) as f:
        for line in f:
            p = line.split()
            if "duration" in p[0]:
                times.append(float(p[1]))
    return times
    
def save_times(filename, times):
    with open(filename, 'w', newline='\n') as f:
        csvwriter = csv.writer(f, delimiter=',')
        for i in range(len(times)):
            csvwriter.writerow([i, times[i]])
    
def save_n(n, directory, substring):
    for i in range(n):
        filename = directory + "output_" + substring + str(i) + ".txt"
        times = parse(filename)
        save_filename = directory + "saved_times_" + substring + str(i) + ".csv"
        save_times(save_filename, times)

            
save_n(10, "ugv_ex_outputs/", "long_")
save_n(10, "ugv_ex_outputs/", "short_")
