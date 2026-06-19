package com.jayrodharv.ngosmpwebappspringboot.viewmodel;

import java.util.List;

import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserDTO;

public record UserListVM(
    List<UserDTO> users,
    int page,
    int totalPages
) {}
