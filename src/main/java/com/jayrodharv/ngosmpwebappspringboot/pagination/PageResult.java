package com.jayrodharv.ngosmpwebappspringboot.pagination;

import java.util.List;

public record PageResult<T>(
    List<T> items,
    int page,
    int size,
    int totalItems,
    int totalPages
) {
    public static <T> PageResult<T> of(
        List<T> items,
        PageRequest request,
        int totalItems) {

        int totalPages = (int) Math.ceil((double) totalItems / request.size());

        return new PageResult<>(
            items,
            request.page(),
            request.size(),
            totalItems,
            totalPages
        );
    }
}
