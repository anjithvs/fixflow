   package com.fixflow.backend.issue;

   import java.util.List;

   import org.springframework.data.jpa.repository.JpaRepository;

   import com.fixflow.backend.user.User;

   public interface IssueRepository extends JpaRepository<Issue, Long> {

       List<Issue> findAllByOrderByCreatedAtDesc();

       List<Issue> findByReporterOrderByCreatedAtDesc(User reporter);

       List<Issue> findByAssignedToOrderByCreatedAtDesc(User assignedTo);
   }