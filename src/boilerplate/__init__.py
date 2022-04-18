from src.boilerplate.custom_logger import LoggerWithMetadata
from src.boilerplate.schemas.common import MetadataOpt

_root_logger = LoggerWithMetadata(name=None)
_root_logger.info('The root logger has been initialized.')
