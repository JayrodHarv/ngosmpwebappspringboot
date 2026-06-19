package com.jayrodharv.ngosmpwebappspringboot.pagination;

import java.util.Set;

public record PageRequest(
    int page,
    int size,
    String search,
    Set<Integer> tagIds,
    boolean descending
) {

    public static final int DEFAULT_SIZE = 20;
    public static final int MAX_SIZE = 100;

    public PageRequest {

        page = Math.max(1, page);

        if (size <= 0) {
            size = DEFAULT_SIZE;
        }

        if (size > MAX_SIZE) {
            size = MAX_SIZE;
        }

        search = search == null
            ? ""
            : search.trim();
    }

    public int offset() {
        return (page - 1) * size;
    }
}
