   package com.fixflow.backend.auth;

   public record AuthResponse(String token, String email, String fullName, String role) {
   }