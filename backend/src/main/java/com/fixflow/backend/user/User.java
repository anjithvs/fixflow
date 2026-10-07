   package com.fixflow.backend.user;

   import jakarta.persistence.Column;
   import jakarta.persistence.Entity;
   import jakarta.persistence.EnumType;
   import jakarta.persistence.Enumerated;
   import jakarta.persistence.GeneratedValue;
   import jakarta.persistence.GenerationType;
   import jakarta.persistence.Id;
   import jakarta.persistence.Table;

   @Entity
   @Table(name = "users")
   public class User {

       @Id
       @GeneratedValue(strategy = GenerationType.IDENTITY)
       private Long id;

       @Column(nullable = false, unique = true)
       private String email;

       @Column(name = "password_hash", nullable = false)
       private String passwordHash;

       @Column(name = "full_name", nullable = false, length = 120)
       private String fullName;

       @Enumerated(EnumType.STRING)
       @Column(nullable = false, length = 20)
       private Role role;

       // JPA needs an empty constructor
       protected User() {
       }

       public User(String email, String passwordHash, String fullName, Role role) {
           this.email = email;
           this.passwordHash = passwordHash;
           this.fullName = fullName;
           this.role = role;
       }

       public Long getId() { return id; }
       public String getEmail() { return email; }
       public String getPasswordHash() { return passwordHash; }
       public String getFullName() { return fullName; }
       public Role getRole() { return role; }
   }