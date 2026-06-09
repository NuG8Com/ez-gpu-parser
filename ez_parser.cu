/*
 * ez_parser.cu
 * CUDA-accelerated parser for ez:// URI scheme
 * V0.0 Genesis - Reference implementation for IANA Ticket #1453765
 * Spec: https://spec.nug8.com v0.0-rev2
 *
 * Parses ez://R.domain.T format with fixed bounds checking
 * R: max 63 bytes, domain: max 63 bytes, T: max 15 bytes
 */

#include <cuda_runtime.h>
#include <stdio.h>
#include <string.h>

#define MAX_URL_LEN 128
#define MAX_R 63
#define MAX_DOMAIN 63
#define MAX_T 15
#define THREADS 1024

struct EzParsed {
    char resource[MAX_R + 1];
    char domain[MAX_DOMAIN + 1];
    char tld[MAX_T + 1];
    int valid;
};

__global__ void parse_ez_kernel(char* urls, EzParsed* results, int count) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= count) return;

    char* url = urls + idx * MAX_URL_LEN;
    EzParsed* res = &results[idx];
    res->valid = 0;
    res->resource[0] = '\0';
    res->domain[0] = '\0';
    res->tld[0] = '\0';

    // Check prefix: ez://
    if (url[0]!= 'e' || url[1]!= 'z' || url[2]!= ':' ||
        url[3]!= '/' || url[4]!= '/') return;

    char* start = url + 5;
    if (*start == '\0') return;

    // Find first dot: R.domain.T
    char* dot1 = start;
    while (*dot1 && *dot1!= '.') dot1++;
    if (*dot1!= '.') return;

    int r_len = dot1 - start;
    if (r_len == 0 || r_len > MAX_R) return;
    memcpy(res->resource, start, r_len);
    res->resource[r_len] = '\0';

    // Find second dot: R.domain.T
    char* dot2 = dot1 + 1;
    while (*dot2 && *dot2!= '.') dot2++;
    if (*dot2!= '.') return;

    int d_len = dot2 - dot1 - 1;
    if (d_len == 0 || d_len > MAX_DOMAIN) return;
    memcpy(res->domain, dot1 + 1, d_len);
    res->domain[d_len] = '\0';

    // Parse T: class label
    char* t_start = dot2 + 1;
    int t_len = 0;
    while (t_start[t_len] && t_start[t_len]!= '/' && t_start[t_len]!= '?' && t_start[t_len]!= '#') {
        t_len++;
    }
    if (t_len == 0 || t_len > MAX_T) return;
    memcpy(res->tld, t_start, t_len);
    res->tld[t_len] = '\0';

    res->valid = 1;
}

int main() {
    const int N = 1000000;
    size_t urls_size = N * MAX_URL_LEN;
    size_t results_size = N * sizeof(EzParsed);

    // Host memory
    char* h_urls = (char*)malloc(urls_size);
    EzParsed* h_results = (EzParsed*)malloc(results_size);

    // Generate test data: ez://resource0.NuG8.com to ez://resource999.NuG8.com
    for (int i = 0; i < N; i++) {
        snprintf(h_urls + i * MAX_URL_LEN, MAX_URL_LEN, "ez://resource%d.NuG8.com", i);
    }

    // Device memory
    char* d_urls;
    EzParsed* d_results;
    cudaMalloc(&d_urls, urls_size);
    cudaMalloc(&d_results, results_size);

    // Copy to device
    cudaMemcpy(d_urls, h_urls, urls_size, cudaMemcpyHostToDevice);

    // Launch kernel
    int blocks = (N + THREADS - 1) / THREADS;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    parse_ez_kernel<<<blocks, THREADS>>>(d_urls, d_results, N);
    cudaDeviceSynchronize();

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);

    // Copy back
    cudaMemcpy(h_results, d_results, results_size, cudaMemcpyDeviceToHost);

    // Verify results
    int valid_count = 0;
    for (int i = 0; i < N; i++) {
        if (h_results[i].valid) valid_count++;
    }

    printf("=== ez:// GPU Parser V0.0 ===\n");
    printf("URIs processed: %d\n", N);
    printf("Valid URIs parsed: %d/%d\n", valid_count, N);
    printf("GPU time: %.4f ms\n", ms);
    printf("Throughput: %.2f M URIs/sec\n", N / (ms / 1000.0) / 1e6);
    printf("\nSample parse: ez://resource999.NuG8.com\n");
    printf(" R = %s\n", h_results[999].resource);
    printf(" domain = %s\n", h_results[999].domain);
    printf(" T = %s\n", h_results[999].tld);
    printf("\nReference: IANA Ticket #1453765 V0.0\n");

    // Cleanup
    cudaFree(d_urls);
    cudaFree(d_results);
    free(h_urls);
    free(h_results);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
