from nvitop import Device

devices = Device.all()  # or `Device.cuda.all()` to use CUDA ordinal instead


# TODO: output this to a file every second once the measurements begin
for device in devices:
    processes = device.processes()  # type: Dict[int, GpuProcess]
    sorted_pids = sorted(processes.keys())

    memory_total = device.memory_total()
    memory_used = device.memory_used()
    memory_usage_percentage = round((memory_used / memory_total) * 100, 2)

    print(device)
    print(f'  - Fan speed:       {device.fan_speed()}%')
    print(f'  - Temperature:     {device.temperature()}C')
    print(f'  - GPU utilization: {device.gpu_utilization()}%')
    print(f'  - Memory usage:    {memory_usage_percentage}%')
    print(f'  - Total memory:    {device.memory_total_human()}')
    print(f'  - Used memory:     {device.memory_used_human()}')
    print(f'  - Free memory:     {device.memory_free_human()}')
    print(f'  - Processes ({len(processes)}): {sorted_pids}')
    for pid in sorted_pids:
        print(f'    - {processes[pid]}')
    print('-' * 120)