int Argmax(int *arr, int arr_len) {
    if (arr_len < 1) {
        a0 = 36;
        j exit;
    }

    int max_number = *arr;
    int max_idx = 0;
    for (int i = 1; i < arr_len; i++) {
        if (*(arr + i) > max_number) {
            max_number = *(arr + i);
            max_idx = i;
        }
    }

    return max_idx;
}