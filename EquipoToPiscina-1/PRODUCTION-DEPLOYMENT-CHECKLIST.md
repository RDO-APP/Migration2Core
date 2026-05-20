# PRODUCTION DEPLOYMENT CHECKLIST

## PRE-DEPLOYMENT (MANDATORY)
- [ ] 1. Create database backup: `./backup-database.ps1`
- [ ] 2. Create application backup: `./backup-application.ps1`
- [ ] 3. Verify backup files exist and have reasonable size
- [ ] 4. Test application compilation: `dotnet build --configuration Release`
- [ ] 5. Verify all tests pass: `dotnet test` (if tests exist)
- [ ] 6. Check disk space on production server
- [ ] 7. Notify users of maintenance window

## DEPLOYMENT STEPS
- [ ] 8. Stop production application
- [ ] 9. Deploy new application files
- [ ] 10. Update database schema (if needed)
- [ ] 11. Update configuration files
- [ ] 12. Start application
- [ ] 13. Verify application starts successfully
- [ ] 14. Test critical functionality (login, main features)
- [ ] 15. Monitor application logs for errors

## POST-DEPLOYMENT VERIFICATION
- [ ] 16. Test user authentication
- [ ] 17. Test API endpoints
- [ ] 18. Verify database connectivity
- [ ] 19. Check application performance
- [ ] 20. Monitor system resources (CPU, memory)
- [ ] 21. Verify security headers are present
- [ ] 22. Test HTTPS redirection

## ROLLBACK PROCEDURES (IF NEEDED)
- [ ] 23. Stop failed application
- [ ] 24. Restore database: `./rollback-database.ps1 <backup-file>`
- [ ] 25. Restore application: `./rollback-application.ps1 <backup-zip>`
- [ ] 26. Verify rollback successful
- [ ] 27. Notify users of rollback completion

## EMERGENCY CONTACTS
- Database Admin: [YOUR_DBA_CONTACT]
- System Admin: [YOUR_SYSADMIN_CONTACT]
- Application Owner: [YOUR_CONTACT]

## BACKUP LOCATIONS
- Database Backups: `backups/database/`
- Application Backups: `backups/application/`
- Deployment Logs: `backups/logs/`

## ROLLBACK TIME ESTIMATES
- Database Rollback: 5-10 minutes
- Application Rollback: 2-5 minutes
- Total Rollback Time: 10-15 minutes

## SUCCESS CRITERIA
- Application starts without errors
- Users can login successfully
- API endpoints respond correctly
- Database queries execute normally
- No critical errors in logs
- Performance within acceptable limits
