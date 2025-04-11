import boto3
import time
import logging
from botocore.exceptions import ClientError

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

iam_client = boto3.client('iam')

# Strong default password that meets typical AWS policy (you can randomize it later)
DEFAULT_TEMP_PASSWORD = "TempPassword@123!"

def add_user_to_group_with_retry(user_name, group_name, retries=5, delay=5):
    for attempt in range(1, retries + 1):
        try:
            iam_client.get_user(UserName=user_name)
            iam_client.add_user_to_group(UserName=user_name, GroupName=group_name)
            logger.info(f"✅ Attempt {attempt}: User '{user_name}' added to group '{group_name}'")
            return {"status": "success", "user": user_name}
        except iam_client.exceptions.NoSuchEntityException:
            logger.warning(f"❌ Attempt {attempt}: User '{user_name}' not found, retrying in {delay} seconds...")
            time.sleep(delay)
        except Exception as e:
            logger.error(f"❌ Attempt {attempt}: Unexpected error: {e}")
            time.sleep(delay)
    return {"status": "failed", "user": user_name, "reason": "User not found after retries"}

def set_or_update_login_profile(user_name, password=DEFAULT_TEMP_PASSWORD):
    try:
        # Try updating login profile
        iam_client.update_login_profile(
            UserName=user_name,
            Password=password,
            PasswordResetRequired=True
        )
        logger.info(f"🔐 Updated login profile for user '{user_name}'")
    except iam_client.exceptions.NoSuchEntityException:
        # Create login profile if it does not exist
        iam_client.create_login_profile(
            UserName=user_name,
            Password=password,
            PasswordResetRequired=True
        )
        logger.info(f"🆕 Created login profile for user '{user_name}'")
    except ClientError as e:
        logger.error(f"❌ Could not set login profile for '{user_name}': {e}")
        raise

def get_most_recent_user():
    users = iam_client.list_users()['Users']
    if not users:
        raise Exception("No IAM users found in account.")
    sorted_users = sorted(users, key=lambda x: x['CreateDate'], reverse=True)
    return sorted_users[0]['UserName']

def lambda_handler(event, context):
    print("🔍 EVENT RECEIVED:")
    print(event)
    group_name = "MFARequired"

    try:
        user_name = event.get("detail", {}).get("requestParameters", {}).get("userName") or event.get("userName")

        if not user_name:
            logger.info("📌 No userName in event, fetching most recently created user...")
            user_name = get_most_recent_user()
            logger.info(f"🆕 Using most recent user: {user_name}")

        result = add_user_to_group_with_retry(user_name, group_name)

        if result["status"] == "success":
            set_or_update_login_profile(user_name)

        return result

    except Exception as e:
        logger.exception(f"❌ Lambda handler failed: {e}")
        return {"status": "failed", "reason": str(e)}