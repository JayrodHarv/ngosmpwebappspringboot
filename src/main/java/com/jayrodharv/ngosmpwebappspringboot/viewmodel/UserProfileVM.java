package com.jayrodharv.ngosmpwebappspringboot.viewmodel;

public record UserProfileVM(
    Integer userId,
    String displayName,
    String pfpPath,
    boolean canEdit
) {}
